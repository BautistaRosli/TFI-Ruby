class CreateDisks < ActiveRecord::Migration[8.0]
  def change
    create_table :disks do |t|
      t.string  :type                        # STI: "NewDisk" or "UsedDisk"
      t.string  :name,       null: false
      t.text    :description
      t.string  :author
      t.decimal :unit_price, precision: 10, scale: 2, default: 0.0, null: false
      t.integer :stock
      t.string  :category
      t.string  :format                      # "vinilo" or "CD"
      t.datetime :date_ingreso
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :disks, :type
    add_index :disks, :deleted_at
  end
end
