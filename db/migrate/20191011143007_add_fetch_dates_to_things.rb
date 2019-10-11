class AddFetchDatesToThings < ActiveRecord::Migration[5.2]
  def change
    change_table :things do |t|
      t.boolean  :deleted, default: false
      t.datetime :category_updated
      t.datetime :tag_updated
      t.datetime :file_updated
      # t.string   :category_updated_state
      # t.string   :tag_updated_state
      # t.string   :file_updated_state
      # t.references :parent, index: true
      add_index :things, :category_updated
      add_index :things, :tag_updated
      add_index :things, :file_updated
    end 
  end
end
