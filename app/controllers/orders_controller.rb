class OrdersController < ApplicationController
 before_action :authenticate_request, only: [:create, :index]
include Rails.application.routes.url_helpers
  def create
    cart = current_user.cart
    cart_items = cart.cart_items.includes(:product)

    if cart_items.empty?
      render json: { error: 'Cart is empty' }, status: :unprocessable_entity
      return
    end

    order = current_user.orders.create!(
      status: 'pending',
      total_price: cart_items.sum { |item| item.quantity * item.product.price }
    )

    cart_items.each do |cart_item|
      order.order_items.create!(
        product: cart_item.product,
        quantity: cart_item.quantity,
        price: cart_item.product.price
      )
    end

    cart.cart_items.destroy_all

    render json: {
      order_id: order.id,
      message: 'Order created successfully',
      total: order.total_price
    }, status: :created
  end

 def index
  orders = current_user.orders
    .includes(order_items: { product: { image_attachment: :blob } })
    .order(created_at: :desc)

  render json: orders.map { |order|
    {
      id: order.id,
      status: order.status,
      total_price: order.total_price,
      created_at: order.created_at,
      order_items: order.order_items.map do |item|
        product = item.product
        {
          id: item.id,
          quantity: item.quantity,
          price: item.price,
          product: {
            id: product.id,
            name: product.name,
            price: product.price,
            image_url: product.image.attached? ? url_for(product.image) : nil
          }
        }
      end   
    }
  }
end

end
