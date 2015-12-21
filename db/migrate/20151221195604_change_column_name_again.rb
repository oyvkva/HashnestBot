class ChangeColumnNameAgain < ActiveRecord::Migration
  def change
    rename_column :datasets, :sellVolume, :s3_sellVolume
  end
end

