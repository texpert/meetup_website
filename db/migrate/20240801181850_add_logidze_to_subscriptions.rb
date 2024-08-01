class AddLogidzeToSubscriptions < ActiveRecord::Migration[7.1]
  def change
    add_column :subscriptions, :log_data, :jsonb

    reversible do |dir|
      dir.up do
        create_trigger :logidze_on_subscriptions, on: :subscriptions
      end

      dir.down do
        execute <<~SQL
          DROP TRIGGER IF EXISTS "logidze_on_subscriptions" on "subscriptions";
        SQL
      end
    end
  end
end
