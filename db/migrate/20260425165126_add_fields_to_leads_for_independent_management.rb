class AddFieldsToLeadsForIndependentManagement < ActiveRecord::Migration[7.1]
  def change
    # Make project_id and property_id optional for independent leads
    change_column_null :leads, :project_id, true
    change_column_null :leads, :property_id, true
    
    # Add new property-related fields for independent leads
    add_column :leads, :property_name, :string
    add_column :leads, :property_location, :string
    add_column :leads, :property_type, :string
    add_column :leads, :follow_up_date, :date
  end
end
