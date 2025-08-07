# app/controllers/webhooks_controller.rb
class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_request

  def stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = Rails.application.credentials.dig(:stripe, :webhook_secret)

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError
      return render json: { error: 'Invalid payload' }, status: 400
    rescue Stripe::SignatureVerificationError
      return render json: { error: 'Invalid signature' }, status: 400
    end

    case event['type']
    when 'checkout.session.completed'
      session = event['data']['object']
      handle_successful_checkout(session)
    end

    render json: { message: 'Success' }
  end

  private

  def handle_successful_checkout(session)
    user_id = session.dig('metadata', 'user_id')
    return unless user_id

    user = User.find_by(id: user_id)
    return unless user

    cart = user.cart
    cart_items = cart.cart_items.includes(:product)
    return if cart_items.empty?

    # Calculate total
    total_price = cart_items.sum { |item| item.quantity * item.product.price }

    # Create order
    order = user.orders.create!(
      status: 'paid',
      total_price: total_price,
      stripe_session_id: session.id,
      stripe_payment_intent_id: session.payment_intent
    )

    # Fetch payment intent details
    intent = Stripe::PaymentIntent.retrieve(session.payment_intent)

    # Update with receipt + method
    order.update!(
      payment_method: intent.payment_method_types.first,
      receipt_url: intent.charges.data.first.receipt_url
    )

    # Create order items
    cart_items.each do |cart_item|
      order.order_items.create!(
        ordered_at: Time.current,
        product: cart_item.product,
        quantity: cart_item.quantity,
        price: cart_item.product.price
      )
    end

    # Clear cart (make sure associations are correct)
    cart_items.destroy_all
  end
end
