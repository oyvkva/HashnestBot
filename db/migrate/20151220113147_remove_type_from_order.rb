class RemoveTypeFromOrder < ActiveRecord::Migration
  def change
    remove_column :orders, :type, :string
  end
end
