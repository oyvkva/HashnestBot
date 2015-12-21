class AddBuyVolumeAndSellVolumeToDatasets < ActiveRecord::Migration
  def change
    add_column :datasets, :buyVolume, :float
    add_column :datasets, :sellVolume, :float
  end
end
