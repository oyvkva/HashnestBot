class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :type
      t.float :price
      t.integer :amount

      t.timestamps null: false
    end
  end
end
