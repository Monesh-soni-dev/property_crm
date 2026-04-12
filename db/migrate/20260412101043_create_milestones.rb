class CreateMilestones < ActiveRecord::Migration[7.1]
  def change
    create_table :milestones do |t|
      t.references :construction_site, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.date :planned_date
      t.date :actual_date
      t.string :status
      t.integer :completion_pct

      t.timestamps
    end
  end
end
