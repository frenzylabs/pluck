class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    execute "CREATE EXTENSION IF NOT EXISTS citext"
    create_table :users do |t|
      t.integer :thingiverse_id
      t.citext :name
      t.string :first_name
      t.string :last_name

      t.timestamps
    end
    add_index :users, :thingiverse_id, unique: true
    add_index :users, :name, unique: true
  end
end
