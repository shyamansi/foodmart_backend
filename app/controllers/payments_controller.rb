class PaymentsController < ApplicationController
  skip_before_action :authenticate_request, only: [:success, :cancel]

  def create
    # Expecting params[:items] to be an array of hashes like:
    # [{ name: "Product A", unit_amount: 1200, quantity: 2 }, { name: "Product B", unit_amount: 800, quantity: 1 }]
    items = params[:items] || []

    # Build line items for Stripe
    line_items = items.map do |item|
      {
        price_data: {
          currency: 'inr',
          product_data: {
            name: item[:name] || 'Unnamed Product'
          },
          unit_amount: item[:unit_amount].to_i
        },
        quantity: item[:quantity].to_i
      }
    end

    # Create Stripe session
    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      mode: 'payment',
      line_items: line_items,
      success_url: 'http://localhost:3001/payment-success',
      cancel_url: 'http://localhost:3001/payment-cancel',
      metadata: {
        user_id: current_user.id
      }
    )

    render json: { id: session.id }
  end

  def success
    render json: { message: "Payment successful!" }
  end

  def cancel
    render json: { message: "Payment canceled." }
  end
end
