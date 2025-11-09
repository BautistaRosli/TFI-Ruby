class ChangeStatusToIsActiveInUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :status, :string
    add_column :users, :is_active, :boolean, default: true
  end
end
