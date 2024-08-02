class AddLogidzeToProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :profiles, :log_data, :jsonb

    reversible do |dir|
      dir.up do
        create_trigger :logidze_on_profiles, on: :profiles
      end

      dir.down do
        execute <<~SQL
          DROP TRIGGER IF EXISTS "logidze_on_profiles" on "profiles";
        SQL
      end
    end
  end
end
