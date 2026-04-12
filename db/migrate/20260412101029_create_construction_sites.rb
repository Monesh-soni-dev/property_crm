class CreateConstructionSites < ActiveRecord::Migration[7.1]
  def change
    create_table :construction_sites do |t|
      t.references :project, null: false, foreign_key: true
      t.string :name
      t.string :site_manager
      t.string :status
      t.date :start_date
      t.date :expected_completion
      t.integer :overall_progress

      t.timestamps
    end
  end
end
