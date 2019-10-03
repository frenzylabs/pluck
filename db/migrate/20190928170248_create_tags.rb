class CreateTags < ActiveRecord::Migration[5.2]
  def change
    create_table :tags do |t|
      t.citext :name
      t.boolean :manual, default: false
      t.integer :thing_count, default: 0
      t.timestamps
    end
    add_index :tags, :name, unique: true

    create_table :tag_things do |t|
      t.references :tag
      t.references :thing
      t.boolean :manual, default: false
      t.timestamps
    end
    add_index :tag_things, [:tag_id, :thing_id], unique: true
  end
end
