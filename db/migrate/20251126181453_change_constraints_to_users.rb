class ChangeConstraintsToUsers < ActiveRecord::Migration[8.0]
  def change
    change_column_null :users, :name, false
    change_column_null :users, :lastname, false
    
    change_column :users, :name, :string, limit: 50
    change_column :users, :lastname, :string, limit: 50
    change_column :users, :email, :string, limit: 255

    change_column_default :users, :is_active, from: nil, to: true
    change_column_null :users, :is_active, false
  end
end
