class AddDeletedToSales < ActiveRecord::Migration[8.0]
  def change
    add_column :sales, :deleted, :boolean
  end
end
