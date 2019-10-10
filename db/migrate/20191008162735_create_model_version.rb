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
      t.references :model_version, index: false
      t.references :thing
      t.references :thing_file, index: false
      t.timestamps
    end
    add_index :model_version_images, [:model_version_id, :index], unique: true
    add_index :model_version_images, [:model_version_id, :thing_file_id], unique: true
  end
end
