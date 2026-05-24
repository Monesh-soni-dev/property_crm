class ExtendMaterialsForEstimates < ActiveRecord::Migration[7.1]
  def change
    change_column_null :materials, :construction_site_id, true

    add_reference :materials, :material_category, foreign_key: true
    add_column :materials, :specification, :text

    add_index :materials, [:material_category_id, :name]
  end
end