class CreateMaterialCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :material_categories do |t|
      t.string :name, null: false
      t.integer :display_order, null: false, default: 0

      t.timestamps
    end

    add_index :material_categories, :name, unique: true
    add_index :material_categories, :display_order
  end
end