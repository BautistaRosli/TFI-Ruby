class AddYearToDisks < ActiveRecord::Migration[8.0]
  def change
    add_column :disks, :year, :integer, null: false
    add_index :disks, :year
  end
end