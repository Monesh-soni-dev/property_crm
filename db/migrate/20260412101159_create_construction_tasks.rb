class CreateConstructionTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :construction_tasks do |t|
      t.references :milestone, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.string :status
      t.string :priority
      t.date :due_date
      t.datetime :completed_at

      t.timestamps
    end
  end
end
