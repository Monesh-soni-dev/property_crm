class CreateWorkers < ActiveRecord::Migration[7.1]
  def change
    create_table :workers do |t|
      t.references :construction_site, null: false, foreign_key: true
      t.string :name
      t.string :role
      t.string :phone
      t.decimal :daily_wage
      t.string :contractor_name
      t.string :status

      t.timestamps
    end
  end
end
