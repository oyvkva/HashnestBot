class AddS4BuyVolumeAndS4SellVolumeToDatasets < ActiveRecord::Migration
  def change
    add_column :datasets, :s4_buyVolume, :float
    add_column :datasets, :s4_sellVolume, :float
  end
end
