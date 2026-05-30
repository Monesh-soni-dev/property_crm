class MakePropertyIdNullableInLeads < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :leads, :properties

    add_foreign_key :leads, :properties, on_delete: :nullify
  end
end