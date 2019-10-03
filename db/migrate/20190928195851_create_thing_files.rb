class CreateThingFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :thing_files do |t|
      t.citext :name
      t.integer :thingiverse_id
      t.integer :download_count
      t.references :thing

      t.timestamps
    end
    add_index :thing_files, :thingiverse_id, unique: true
  end
end
