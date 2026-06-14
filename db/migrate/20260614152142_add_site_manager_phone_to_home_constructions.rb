class AddSiteManagerPhoneToHomeConstructions < ActiveRecord::Migration[7.1]
  def change
    add_column :home_constructions, :site_manager_phone, :string
  end
end
