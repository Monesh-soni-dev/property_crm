class CreateConstructionEstimates < ActiveRecord::Migration[7.1]
  def change
    create_table :construction_estimates do |t|
      t.references :user, null: false, foreign_key: true
      t.references :property, foreign_key: true
      t.decimal :plot_length, precision: 10, scale: 2, null: false
      t.decimal :plot_width, precision: 10, scale: 2, null: false
      t.decimal :plot_area, precision: 12, scale: 2, null: false, default: 0
      t.decimal :construction_area, precision: 12, scale: 2, null: false, default: 0
      t.integer :number_of_floors, null: false, default: 1
      t.string :city, null: false
      t.string :quality_tier, null: false, default: 'standard'
      t.decimal :total_estimated_cost, precision: 14, scale: 2, null: false, default: 0
      t.decimal :cost_per_sqft, precision: 12, scale: 2, null: false, default: 0
      t.string :status, null: false, default: 'draft'
      t.string :share_token, null: false
      t.integer :version_number, null: false, default: 1
      t.datetime :finalized_at

      t.timestamps
    end

    add_index :construction_estimates, [:user_id, :created_at]
    add_index :construction_estimates, :city
    add_index :construction_estimates, :quality_tier
    add_index :construction_estimates, :share_token, unique: true
  end
end