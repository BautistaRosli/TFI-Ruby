class CreateClients < ActiveRecord::Migration[8.0]
  def change
    create_table :clients do |t|
      t.timestamps
      t.string :name
      t.string :lastname
      t.string :email
      t.string :document_type, limit: 10, default: 'DNI', null: false
      t.string :document_number, limit: 30, null: false
    end
    add_index :clients, [ :document_type, :document_number ], unique: true
    add_index :clients, :email, unique: true
  end
end
