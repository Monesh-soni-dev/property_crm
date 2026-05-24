class CreateMaterialPrices < ActiveRecord::Migration[7.1]
  def change
    create_table :material_prices do |t|
      t.references :material, null: false, foreign_key: true
      t.string :city, null: false
      t.decimal :price_per_unit, precision: 12, scale: 2, null: false
      t.string :quality_tier, null: false
      t.date :effective_from, null: false
      t.boolean :is_active, null: false, default: true

      t.timestamps
    end

    add_index :material_prices, [:material_id, :city, :quality_tier, :effective_from], unique: true, name: 'index_material_prices_on_lookup_fields'
    add_index :material_prices, [:city, :quality_tier, :is_active], name: 'index_material_prices_on_city_tier_active'
  end
end