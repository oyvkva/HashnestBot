class DropPrices < ActiveRecord::Migration
  def change
    drop_table :prices
  end
end
