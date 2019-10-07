class AddImageUrlToThingFiles < ActiveRecord::Migration[5.2]
  def change
    change_table :thing_files do |t|
      t.string :image_url
      # t.references :parent, index: true
    end    
  end
end
