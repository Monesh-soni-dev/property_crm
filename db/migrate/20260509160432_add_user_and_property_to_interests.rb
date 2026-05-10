class AddUserAndPropertyToInterests < ActiveRecord::Migration[7.1]
  def change
    # Only add user_id since property_id already exists
    add_column :interests, :user_id, :string
    # Add unique composite index to prevent duplicate interests
    add_index :interests, [:user_id, :property_id], unique: true, name: 'index_interests_on_user_and_property'
  end
end
