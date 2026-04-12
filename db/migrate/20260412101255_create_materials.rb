class CreateMaterials < ActiveRecord::Migration[7.1]
  def change
    create_table :materials do |t|
      t.references :construction_site, null: false, foreign_key: true
      t.string :name
      t.string :unit
      t.float :quantity_ordered
      t.float :quantity_received
      t.float :quantity_used
      t.decimal :unit_price
      t.string :vendor
      t.date :last_updated

      t.timestamps
    end
  end
end
