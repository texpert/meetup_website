class AddLogidzeToEmails < ActiveRecord::Migration[7.1]
  def change
    add_column :emails, :log_data, :jsonb

    reversible do |dir|
      dir.up do
        create_trigger :logidze_on_emails, on: :emails
      end

      dir.down do
        execute <<~SQL
          DROP TRIGGER IF EXISTS "logidze_on_emails" on "emails";
        SQL
      end
    end
  end
end
