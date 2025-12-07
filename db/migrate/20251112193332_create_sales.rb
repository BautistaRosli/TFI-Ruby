class CreateSales < ActiveRecord::Migration[8.0]
  def change
    create_table :sales do |t|
      t.datetime :datetime
      t.decimal :total_amount
      t.integer :employee_id
      t.integer :customer_id

      t.timestamps
    end
  end
end
