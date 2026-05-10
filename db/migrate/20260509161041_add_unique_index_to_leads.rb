class AddUniqueIndexToLeads < ActiveRecord::Migration[7.1]
  def change
    # Add unique composite index to prevent duplicate leads
    add_index :leads, [:user_id, :property_id], unique: true, name: 'index_leads_on_user_and_property'
  end
end
