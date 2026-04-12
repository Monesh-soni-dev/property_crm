class CreateProperties < ActiveRecord::Migration[7.1]
  def change
    create_table :properties do |t|
      t.references :project, null: false, foreign_key: true
      t.string :title
      t.string :unit_number
      t.integer :floor
      t.string :property_type
      t.decimal :price
      t.float :area
      t.integer :bedrooms
      t.integer :bathrooms
      t.string :facing
      t.string :status
      t.text :description

      t.timestamps
    end
  end
end
