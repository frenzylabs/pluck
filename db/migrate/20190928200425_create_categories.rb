class CreateCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :categories do |t|
      t.citext :name
      t.string :url
      t.timestamps
    end

    create_table :category_things do |t|
      t.references :category
      t.references :thing
      t.timestamps
    end
    add_index :category_things, [:category_id, :thing_id], unique: true    
  end
end
