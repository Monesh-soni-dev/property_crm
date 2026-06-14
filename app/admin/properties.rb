ActiveAdmin.register Property do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :project_id, :title, :unit_number, :floor, :property_type, :price, :area, :bedrooms, :bathrooms, :facing, :status, :description, :user_id, :contact_phone, :contact_email, :website, :contact_person, :additional_contact, :city, :state, :pincode, :address, :features, :age_of_property, :possession_status, :parking, :furnishing_status, :water_supply, :power_backup, :road_width, :location_advantage, :transaction_type, :ownership_type, :boundary_wall, :flooring_type
  #
  # or
  #
  # permit_params do
  #   permitted = [:project_id, :title, :unit_number, :floor, :property_type, :price, :area, :bedrooms, :bathrooms, :facing, :status, :description, :user_id, :contact_phone, :contact_email, :website, :contact_person, :additional_contact, :city, :state, :pincode, :address, :features, :age_of_property, :possession_status, :parking, :furnishing_status, :water_supply, :power_backup, :road_width, :location_advantage, :transaction_type, :ownership_type, :boundary_wall, :flooring_type]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
end
