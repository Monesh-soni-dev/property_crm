class AddMaterialRatesToConstructionEstimates < ActiveRecord::Migration[7.1]
  def change
    add_column :construction_estimates, :material_rates, :jsonb, null: false, default: {}
  end
end