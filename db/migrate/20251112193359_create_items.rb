class CreateItems < ActiveRecord::Migration[8.0]
  def change
    create_table :items do |t|
      t.decimal :price
      t.string :description
      t.integer :units_sold
      t.references :sale, null: false, foreign_key: true
      t.integer :product_id

      t.timestamps
    end
  end
end
