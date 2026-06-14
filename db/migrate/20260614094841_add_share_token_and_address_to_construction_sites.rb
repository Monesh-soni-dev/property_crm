class AddShareTokenAndAddressToConstructionSites < ActiveRecord::Migration[7.1]
  def change
    add_column :construction_sites, :share_token, :string
    add_index :construction_sites, :share_token, unique: true
    add_column :construction_sites, :address, :string
    add_column :construction_sites, :customer_notes, :text
  end
end
