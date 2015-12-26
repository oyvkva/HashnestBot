class CreatePricepoints < ActiveRecord::Migration
  def change
    create_table :pricepoints do |t|
      t.string :name
      t.float :price

      t.timestamps null: false
    end
  end
end
