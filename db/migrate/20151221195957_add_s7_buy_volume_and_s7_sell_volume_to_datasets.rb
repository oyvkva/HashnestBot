class AddS7BuyVolumeAndS7SellVolumeToDatasets < ActiveRecord::Migration
  def change
    add_column :datasets, :s7_buyVolume, :float
    add_column :datasets, :s7_sellVolume, :float
  end
end
