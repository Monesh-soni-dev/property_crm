class ModifyLeadsForIndependentLeadManagement < ActiveRecord::Migration[7.1]
  def change
    # Make project_id and property_id optional (for independent leads)
    change_column_null :leads, :project_id, true
    change_column_null :leads, :property_id, true
    
    # Rename fields to match user requirements 
    rename_column :leads, :name, :customer_name
    rename_column :leads, :email, :customer_email
    rename_column :leads, :phone, :customer_phone
    
    # Add new property-related fields
    add_column :leads, :property_name, :string
    add_column :leads, :property_location, :string
    add_column :leads, :property_type, :string
    
    # Change follow_up_at to follow_up_date (date instead of datetime)
    remove_column :leads, :follow_up_at, :datetime
    add_column :leads, :follow_up_date, :date
  end
end
