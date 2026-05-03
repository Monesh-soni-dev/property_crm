class CreateInterests < ActiveRecord::Migration[7.1]
  def change
    create_table :interests do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.text :message
      t.references :property, null: false, foreign_key: true

      t.timestamps
    end
  end
end
