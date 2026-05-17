class CreatePropertyCosts < ActiveRecord::Migration[7.1]
  def change
    create_table :property_costs do |t|
      t.references :user,     null: false, foreign_key: true
      t.references :property, null: true,  foreign_key: true
      t.references :project,  null: true,  foreign_key: true
      t.string  :title,          null: false
      t.string  :category,       null: false, default: 'miscellaneous'
      t.decimal :amount,         null: false, precision: 12, scale: 2
      t.date    :cost_date,      null: false
      t.string  :vendor_name
      t.string  :invoice_number
      t.text    :notes
      t.timestamps
    end

    add_index :property_costs, :category
  end
end
