class ChangeDifficultyFormatInDataset < ActiveRecord::Migration
  def up
   change_column :datasets, :difficulty, :bigint
  end

  def down
   change_column :datasets, :difficulty, :integer
  end

end
