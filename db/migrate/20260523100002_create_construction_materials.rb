class CreateConstructionMaterials < ActiveRecord::Migration[7.1]
  def change
    create_table :construction_materials do |t|
      t.references :material_category, null: false, foreign_key: true
      t.string :name, null: false
      t.string :unit, null: false
      t.text :specification

      t.timestamps
    end

    add_index :construction_materials, [:material_category_id, :name], unique: true
  end
end
