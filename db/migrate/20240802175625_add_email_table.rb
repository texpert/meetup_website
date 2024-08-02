class AddEmailTable < ActiveRecord::Migration[7.1]
  def change
    create_enum :email_status, %w[unverified verified unreachable]
    create_enum :email_kind, %w[contact recovery alternative]

    create_table :emails do |t|
      t.bigint "owner_id", null: false
      t.text "owner_type", null: false
      t.citext :address, null: false
      t.enum :status,  enum_type: :email_status, default: 'unverified', null: false
      t.enum :kind,  enum_type: :email_kind, array: true, default: [], null: false
      t.boolean :account_email, default: false, null: false
      t.timestamps
      t.datetime :deleted_at
      t.index :address, unique: true
      t.index :deleted_at
      t.index ["owner_id", "owner_type", "account_email"], name: "index_emails_on_owner_id_owner_type_and_account_email"
    end
  end
end
