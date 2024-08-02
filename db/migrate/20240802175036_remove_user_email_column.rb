class RemoveUserEmailColumn < ActiveRecord::Migration[7.1]
  def up
    safety_assured { remove_index :users, :email }

    safety_assured { remove_column :users, :email }
  end

  def down
    add_column :users, :email, :citext

    safety_assured { add_index :users, :email, unique: true }
  end
end
