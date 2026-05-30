class CreateConstructionEstimates < ActiveRecord::Migration[7.1]
  def change
    create_table :construction_estimates do |t|
      t.references :user, null: false, foreign_key: true
      t.references :property, null: true, foreign_key: true
      t.decimal :plot_length, precision: 10, scale: 2, null: false
      t.decimal :plot_width, precision: 10, scale: 2, null: false
      t.decimal :plot_area, precision: 12, scale: 2, null: false
      t.decimal :construction_area, precision: 12, scale: 2, null: false
      t.integer :number_of_floors, default: 1, null: false
      t.string :city, null: false
      t.integer :quality_tier, default: 0, null: false
      t.decimal :total_estimated_cost, precision: 15, scale: 2
      t.decimal :cost_per_sqft, precision: 10, scale: 2
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    add_index :construction_estimates, :city
    add_index :construction_estimates, :quality_tier
    add_index :construction_estimates, :status
  end
end
