class AddUniqueIndexToLeads < ActiveRecord::Migration[7.1]
  def up
    # Remove duplicate leads, keeping only the most recently created one per (user_id, property_id)
    execute <<-SQL
      DELETE FROM leads
      WHERE id NOT IN (
        SELECT DISTINCT ON (user_id, property_id) id
        FROM leads
        ORDER BY user_id, property_id, created_at DESC
      )
    SQL

    # Add unique composite index to prevent duplicate leads
    add_index :leads, [:user_id, :property_id], unique: true, name: 'index_leads_on_user_and_property'
  end

  def down
    remove_index :leads, name: 'index_leads_on_user_and_property'
  end
end
