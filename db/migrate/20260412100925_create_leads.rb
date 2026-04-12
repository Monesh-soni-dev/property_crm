class CreateLeads < ActiveRecord::Migration[7.1]
  def change
    create_table :leads do |t|
      t.references :project, null: false, foreign_key: true
      t.references :property, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :email
      t.string :phone
      t.string :source
      t.decimal :budget
      t.string :stage
      t.text :notes
      t.datetime :follow_up_at

      t.timestamps
    end
  end
end
