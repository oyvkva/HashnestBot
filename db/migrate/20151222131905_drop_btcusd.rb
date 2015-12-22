class DropBtcusd < ActiveRecord::Migration
  def change
    drop_table :btcusds
  end
end
