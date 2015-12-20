class AddOrdertypeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :ordertype, :string
  end
end
