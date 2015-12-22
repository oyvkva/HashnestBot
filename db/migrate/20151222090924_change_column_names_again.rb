class ChangeColumnNamesAgain < ActiveRecord::Migration
  def change
    rename_column :datasets, :s3_sellVolume, :s3_sellvolume
    rename_column :datasets, :s3_buyVolume, :s3_buyvolume
    rename_column :datasets, :s4_sellVolume, :s4_sellvolume
    rename_column :datasets, :s4_buyVolume, :s4_buyvolume
    rename_column :datasets, :s5_sellVolume, :s5_sellvolume
    rename_column :datasets, :s5_buyVolume, :s5_buyvolume
    rename_column :datasets, :s7_sellVolume, :s7_sellvolume
    rename_column :datasets, :s7_buyVolume, :s7_buyvolume
  end
end
