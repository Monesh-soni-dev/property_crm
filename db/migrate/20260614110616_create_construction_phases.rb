class CreateConstructionPhases < ActiveRecord::Migration[7.1]
  def change
    create_table :construction_phases do |t|
      t.bigint :home_construction_id, null: false
      t.string :name
      t.text :description
      t.integer :phase_order
      t.date :planned_start
      t.date :planned_end
      t.date :actual_start
      t.date :actual_end
      t.string :status
      t.integer :completion_pct
      t.text :notes

      t.timestamps
    end
    add_index :construction_phases, :home_construction_id
  end
end
