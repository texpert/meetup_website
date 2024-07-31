class AddLogidzeToPlans < ActiveRecord::Migration[7.1]
  def change
    add_column :plans, :log_data, :jsonb

    reversible do |dir|
      dir.up do
        create_trigger :logidze_on_plans, on: :plans
      end

      dir.down do
        execute <<~SQL
          DROP TRIGGER IF EXISTS "logidze_on_plans" on "plans";
        SQL
      end
    end
  end
end
