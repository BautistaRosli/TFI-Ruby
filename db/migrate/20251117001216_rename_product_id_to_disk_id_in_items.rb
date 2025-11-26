class RenameProductIdToDiskIdInItems < ActiveRecord::Migration[8.0]
  def change
    rename_column :items, :product_id, :disk_id
    add_index :items, :disk_id
  end
end
