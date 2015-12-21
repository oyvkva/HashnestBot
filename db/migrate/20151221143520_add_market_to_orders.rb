class AddMarketToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :market, :string
  end
end
