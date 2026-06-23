class FixLeadsUniqueIndex < ActiveRecord::Migration[7.1]
  def up
    # Remove the old constraint that prevented one agent from creating
    # multiple leads on the same property for different customers.
    remove_index :leads, name: :index_leads_on_user_and_property, if_exists: true
  end

  def down
    add_index :leads, [:user_id, :property_id],
              unique: true,
              name: :index_leads_on_user_and_property
  end
end
