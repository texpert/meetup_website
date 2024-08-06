class CreateEmailsTable < ActiveRecord::Migration[7.1]
  def change
    enable_extension "citext"

    create_enum :email_status, %w[untried reachable unreachable]
    create_enum :email_kind, %w[contact recovery alternative]

    create_table :emails do |t|
      t.bigint "user_id", null: false
      t.text "user_type", null: false
      t.citext :email, null: false
      t.enum :status,  enum_type: :email_status, default: 'untried', null: false
      t.enum :kind,  enum_type: :email_kind, array: true, default: [], null: false
      t.boolean :primary, default: false, null: false

      ## Confirmable
      t.string :unconfirmed_email
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at

      t.timestamps
      t.datetime :deleted_at
      t.index :email, unique: true
      t.index :deleted_at
      t.index ["user_id", "user_type", "primary"], name: "index_emails_on_user_id_user_type_and_primary"
    end
  end
end
