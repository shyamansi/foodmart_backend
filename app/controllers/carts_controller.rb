class CartsController < ApplicationController
  before_action :authenticate_request
  include Rails.application.routes.url_helpers

  def add_item
    product = Product.find(params[:product_id])
    cart = current_user.cart || current_user.create_cart

    cart_item = cart.cart_items.find_by(product_id: product.id)

    if cart_item
      cart_item.increment!(:quantity)
    else
      cart.cart_items.create(product: product, quantity: 1)
    end

    render json: { success: true }, status: :ok
  end

  def all_items
  Rails.logger.debug "Fetching all items in the cart for user: #{current_user.inspect}"

  cart = current_user.cart || current_user.create_cart

  render json: cart.cart_items.includes(product: { image_attachment: :blob }).map { |item|
    {
      id: item.id,
      product_id: item.product_id,
      name: item.product.name,
      price: item.product.price,
      quantity: item.quantity,
      image_url: url_for(item.product.image) # 👈 This line adds the image URL
    }
  }
end

end
