class CreateJobs < ActiveRecord::Migration[5.2]
  def change
    create_table :jobs do |t|
      t.timestamps
    end
    change_table :things do |t|
      t.references :job, index: true
      # t.references :parent, index: true
    end    
    # add_index :categories, [:name]
  end
end
