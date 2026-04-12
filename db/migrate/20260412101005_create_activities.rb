class CreateActivities < ActiveRecord::Migration[7.1]
  def change
    create_table :activities do |t|
      t.references :lead, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :activity_type
      t.text :description
      t.datetime :occurred_at

      t.timestamps
    end
  end
end
