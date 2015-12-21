class CreateBtcusds < ActiveRecord::Migration
  def change
    create_table :btcusds do |t|
      t.float :price

      t.timestamps null: false
    end
  end
end
