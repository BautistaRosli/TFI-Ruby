class CreateGenresAndJoin < ActiveRecord::Migration[8.0]
  def change
    create_table :genres do |t|
      t.string :name, null: false
      t.timestamps
    end
    add_index :genres, :name, unique: true

    create_table :disks_genres, id: false do |t|
      t.references :disk, null: false, foreign_key: true, index: true
      t.references :genre, null: false, foreign_key: true, index: true
    end
    add_index :disks_genres, [:disk_id, :genre_id], unique: true
  end
end