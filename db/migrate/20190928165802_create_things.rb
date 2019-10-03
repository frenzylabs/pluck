class CreateThings < ActiveRecord::Migration[5.2]
  def change
    create_table :things do |t|
      t.citext :name
      t.integer :thingiverse_id
      t.string :image_url
      t.text   :description
      t.integer :like_count, default: 0
      t.integer :download_count, default: 0
      t.datetime :added_on
      t.datetime :updated_on

      t.references :user
      t.timestamps
    end
    add_index :things, :thingiverse_id, unique: true
  end
end
