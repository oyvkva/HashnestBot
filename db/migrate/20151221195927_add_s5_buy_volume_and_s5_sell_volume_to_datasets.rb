class AddS5BuyVolumeAndS5SellVolumeToDatasets < ActiveRecord::Migration
  def change
    add_column :datasets, :s5_buyVolume, :float
    add_column :datasets, :s5_sellVolume, :float
  end
end
