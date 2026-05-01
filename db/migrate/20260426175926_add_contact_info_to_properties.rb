class AddContactInfoToProperties < ActiveRecord::Migration[7.1]
  def change
    add_column :properties, :contact_phone, :string
    add_column :properties, :contact_email, :string
    add_column :properties, :website, :string
    add_column :properties, :contact_person, :string
    add_column :properties, :additional_contact, :text
  end
end
