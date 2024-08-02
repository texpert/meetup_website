class ChangeUserStatusToPostgresEnum < ActiveRecord::Migration[7.1]
  def up
    safety_assured { remove_column :users, :status }

    create_enum :user_status, %w[staged unverified active recovery expired locked suspended disabled]

    add_column :users, :status, :enum, enum_type: :user_status, default: 'staged', null: false

    safety_assured { add_index :users, :status, using: :btree }
    safety_assured { add_index :users, :email, unique: true }
  end

  def down
    remove_index :users, :status
    remove_index :users, :email
    remove_column :users, :status

    drop_enum :user_status

    add_column :users, :status, :integer, null: false, default: 1

    safety_assured { add_index :users, :email, unique: true, where: "(status = ANY (ARRAY[1, 2]))" }
  end
end
