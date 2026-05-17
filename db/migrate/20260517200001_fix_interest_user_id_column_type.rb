class FixInterestUserIdColumnType < ActiveRecord::Migration[7.1]
  def up
    # Cast existing string values to bigint safely
    change_column :interests, :user_id, :bigint, using: 'NULLIF(user_id, \'\')::bigint'
  end

  def down
    change_column :interests, :user_id, :string
  end
end
