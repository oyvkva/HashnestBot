class CreateDatasets < ActiveRecord::Migration
  def change
    create_table :datasets do |t|
      t.integer :difficulty
      t.float :btc_price
      t.float :s3_btc
      t.float :s4_btc
      t.float :s5_btc
      t.float :s7_btc

      t.timestamps null: false
    end
  end
end
