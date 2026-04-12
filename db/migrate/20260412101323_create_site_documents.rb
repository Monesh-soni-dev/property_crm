class CreateSiteDocuments < ActiveRecord::Migration[7.1]
  def change
    create_table :site_documents do |t|
      t.references :construction_site, null: false, foreign_key: true
      t.references :milestone, null: false, foreign_key: true
      t.string :title
      t.string :document_type
      t.text :description
      t.references :uploaded_by, polymorphic: true, null: false

      t.timestamps
    end
  end
end
