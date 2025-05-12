class LogidzeUpdate131 < ActiveRecord::Migration[8.0]
  def change
    reversible do |dir|
      dir.up do
        # Drop legacy functions (<1.0)
        execute <<~SQL
          DROP FUNCTION IF EXISTS logidze_version(bigint, jsonb);
          DROP FUNCTION IF EXISTS logidze_snapshot(jsonb);
          DROP FUNCTION IF EXISTS logidze_version(bigint, jsonb, text[]);
          DROP FUNCTION IF EXISTS logidze_snapshot(jsonb, text[]);
          DROP FUNCTION IF EXISTS logidze_version(bigint, jsonb, timestamp with time zone, text[]);
          DROP FUNCTION IF EXISTS logidze_snapshot(jsonb, text, text[]);
          DROP FUNCTION IF EXISTS logidze_exclude_keys(jsonb, VARIADIC text[]);
          DROP FUNCTION IF EXISTS logidze_compact_history(jsonb);
        SQL
      end
    end

  end
end
