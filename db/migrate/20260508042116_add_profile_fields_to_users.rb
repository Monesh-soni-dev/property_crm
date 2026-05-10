class AddProfileFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :mobile_number, :string
    add_column :users, :city, :string
    add_column :users, :state, :string
    add_column :users, :address, :string
    add_column :users, :pincode, :string
  end
end
