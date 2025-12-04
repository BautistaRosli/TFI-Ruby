class RemoveCategoryFromDisks < ActiveRecord::Migration[8.0]
  def change
    remove_column :disks, :category, :string
  end
end