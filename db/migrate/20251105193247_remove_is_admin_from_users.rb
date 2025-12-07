class RemoveIsAdminFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :isAdmin, :boolean
  end
end
