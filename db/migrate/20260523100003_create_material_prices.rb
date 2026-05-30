class CreateMaterialPrices < ActiveRecord::Migration[7.1]
  def change
    create_table :material_prices do |t|
      t.references :construction_material, null: false, foreign_key: true
      t.string :city, null: false
      t.decimal :price_per_unit, precision: 12, scale: 2, null: false
      t.integer :quality_tier, default: 0, null: false
      t.date :effective_from, null: false
      t.boolean :is_active, default: true, null: false

      t.timestamps
    end

    add_index :material_prices, [:construction_material_id, :city, :quality_tier, :is_active],
              name: "idx_material_prices_lookup"
    add_index :material_prices, :city
    add_index :material_prices, :is_active
  end
end
