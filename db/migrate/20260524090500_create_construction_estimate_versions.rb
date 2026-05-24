class CreateConstructionEstimateVersions < ActiveRecord::Migration[7.1]
  def change
    create_table :construction_estimate_versions do |t|
      t.references :construction_estimate, null: false, foreign_key: true
      t.integer :version_number, null: false
      t.jsonb :snapshot, null: false, default: {}

      t.timestamps
    end

    add_index :construction_estimate_versions, [:construction_estimate_id, :version_number], unique: true, name: 'index_estimate_versions_on_estimate_and_version'
  end
end