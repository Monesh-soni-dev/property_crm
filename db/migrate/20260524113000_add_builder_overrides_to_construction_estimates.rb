class AddBuilderOverridesToConstructionEstimates < ActiveRecord::Migration[7.1]
  def change
    add_column :construction_estimates, :market_adjustment_percentage, :decimal, precision: 6, scale: 2, null: false, default: 0
    add_column :construction_estimates, :labor_percentage, :decimal, precision: 6, scale: 2, null: false, default: 35
    add_column :construction_estimates, :overhead_percentage, :decimal, precision: 6, scale: 2, null: false, default: 5
    add_column :construction_estimates, :contingency_percentage, :decimal, precision: 6, scale: 2, null: false, default: 10
    add_column :construction_estimates, :electrical_rate_per_sqft, :decimal, precision: 10, scale: 2
    add_column :construction_estimates, :plumbing_rate_per_sqft, :decimal, precision: 10, scale: 2
  end
end