class RemoveDeletedAtAndEmployeeIdFromSales < ActiveRecord::Migration[8.0]
  def change
    remove_column :sales, :deleted_at, :datetime
    remove_column :sales, :employee_id, :integer
  end
end
