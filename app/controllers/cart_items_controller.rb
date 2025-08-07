class CartItemsController < ApplicationController
  before_action :authenticate_request
  before_action :set_cart_item, only: [:update, :destroy]

  def update
    if @cart_item.update(quantity: params[:quantity])
      render json: { success: true }
    else
      render json: { error: 'Failed to update quantity' }, status: :unprocessable_entity
    end
  end

  def destroy
    @cart_item.destroy
    render json: { success: true }
  end

  private

  def set_cart_item
    @cart_item = current_user.cart.cart_items.find(params[:id])
  end
end
