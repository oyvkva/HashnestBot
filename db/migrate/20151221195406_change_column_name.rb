class ChangeColumnName < ActiveRecord::Migration
  def change
    rename_column :datasets, :buyVolume, :s3_buyVolume
  end
end
