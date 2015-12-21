class CreatePrices < ActiveRecord::Migration
  def change
    create_table :prices do |t|
      t.string :market
      t.float :btc_price
      t.float :usd_price
      t.float :return

      t.timestamps null: false
    end
  end
end
