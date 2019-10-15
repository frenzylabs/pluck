class AddActiveToModelVersions < ActiveRecord::Migration[5.2]
  def change
    change_table :model_versions do |t|
      t.boolean  :deleted, default: false
      t.boolean :active, default: true
    end 
  end
end
