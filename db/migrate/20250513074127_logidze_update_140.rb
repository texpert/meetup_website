class LogidzeUpdate140 < ActiveRecord::Migration[8.0]
  def change






    reversible do |dir|
      dir.up do
        create_function :logidze_logger, version: 5
      end

      dir.down do
        create_function :logidze_logger, version: 4
      end
    end


    reversible do |dir|
      dir.up do
        create_function :logidze_logger_after, version: 5
      end

      dir.down do
        create_function :logidze_logger_after, version: 4
      end
    end






  end
end
