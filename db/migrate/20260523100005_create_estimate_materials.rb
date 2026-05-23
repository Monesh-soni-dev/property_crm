class CreateEstimateMaterials < ActiveRecord::Migration[7.1]
  def change
    create_table :estimate_materials do |t|
      t.references :construction_estimate, null: false, foreign_key: true
      t.references :construction_material, null: false, foreign_key: true
      t.decimal :quantity, precision: 12, scale: 2, null: false
      t.decimal :unit_price, precision: 12, scale: 2, null: false
      t.decimal :total_price, precision: 15, scale: 2, null: false
      t.text :calculation_formula

      t.timestamps
    end

    add_index :estimate_materials, [:construction_estimate_id, :construction_material_id],
              unique: true, name: "idx_estimate_materials_unique"
  end
end
