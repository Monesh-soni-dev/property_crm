class CreateHomeConstructions < ActiveRecord::Migration[7.1]
  def change
    create_table :home_constructions do |t|
      t.bigint :user_id, null: false
      t.string :name
      t.string :address
      t.string :city
      t.string :client_name
      t.string :client_phone
      t.string :client_email
      t.string :site_manager
      t.string :status
      t.date :start_date
      t.date :expected_completion
      t.decimal :total_built_area
      t.integer :number_of_floors
      t.text :description
      t.text :customer_notes
      t.string :share_token

      t.timestamps
    end
    add_index :home_constructions, :share_token, unique: true
    add_index :home_constructions, :user_id
  end
end
