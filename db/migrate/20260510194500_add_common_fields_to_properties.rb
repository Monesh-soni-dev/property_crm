class AddCommonFieldsToProperties < ActiveRecord::Migration[7.1]
  def change
    add_column :properties, :city, :string
    add_column :properties, :state, :string
    add_column :properties, :pincode, :string
    add_column :properties, :address, :text
    add_column :properties, :features, :text
    add_column :properties, :age_of_property, :integer
    add_column :properties, :possession_status, :string
    add_column :properties, :parking, :string
    add_column :properties, :furnishing_status, :string
    add_column :properties, :water_supply, :string
    add_column :properties, :power_backup, :string
    add_column :properties, :road_width, :string
    add_column :properties, :location_advantage, :text
    add_column :properties, :transaction_type, :string
    add_column :properties, :ownership_type, :string
    add_column :properties, :boundary_wall, :string
    add_column :properties, :flooring_type, :string
  end
end
