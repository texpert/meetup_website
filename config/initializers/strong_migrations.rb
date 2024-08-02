StrongMigrations.enable_check(:remove_index)
StrongMigrations.lock_timeout = 10.seconds
StrongMigrations.statement_timeout = 1.hour
StrongMigrations.lock_timeout_retries = 3
StrongMigrations.lock_timeout_retry_delay = 10.seconds
StrongMigrations.start_after = 20240801211646
StrongMigrations.auto_analyze = true
