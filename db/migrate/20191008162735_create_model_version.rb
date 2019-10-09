class CreateModelVersion < ActiveRecord::Migration[5.2]
  def change
    create_table :model_versions do |t|
      t.integer    :version
      t.timestamps
    end

    create_table :model_version_images do |t|
      t.citext     :name  
      t.string     :filepath
      t.integer    :index 
      t.jsonb      :metadata,         default: {}
      t.jsonb      :image_data
      t.references :model_version
      t.references :thing
      t.references :thing_file
      t.timestamps
    end
    add_index :model_version_images, [:model_version_id, :index], unique: true
  end
end
