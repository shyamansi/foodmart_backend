class AddPaymentDetailsToOrders < ActiveRecord::Migration[7.2]
  def change
    add_column :orders, :payment_method, :string
    add_column :orders, :receipt_url, :string
  end
end
