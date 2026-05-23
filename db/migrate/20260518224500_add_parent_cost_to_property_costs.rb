class AddParentCostToPropertyCosts < ActiveRecord::Migration[7.0]
  def change
    add_reference :property_costs, :parent_cost, foreign_key: { to_table: :property_costs }, index: true
  end
end
