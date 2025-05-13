# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_05_13_074127) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "hstore"
  enable_extension "pg_catalog.plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "email_kind", ["contact", "recovery", "alternative"]
  create_enum "email_status", ["untried", "reachable", "unreachable"]
  create_enum "user_status", ["staged", "unverified", "active", "recovery", "expired", "locked", "suspended", "disabled"]

  create_table "emails", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "user_type", null: false
    t.citext "email", null: false
    t.enum "status", default: "untried", null: false, enum_type: "email_status"
    t.enum "kind", default: [], null: false, array: true, enum_type: "email_kind"
    t.boolean "primary", default: false, null: false
    t.string "unconfirmed_email"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.jsonb "log_data"
    t.index ["deleted_at"], name: "index_emails_on_deleted_at"
    t.index ["email"], name: "index_emails_on_email", unique: true
    t.index ["user_id", "user_type", "primary"], name: "index_emails_on_user_id_user_type_and_primary"
  end

  create_table "users", force: :cascade do |t|
    t.enum "status", default: "staged", null: false, enum_type: "user_status"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.jsonb "log_data"
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["status"], name: "index_users_on_status"
  end
  create_function :logidze_capture_exception, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.logidze_capture_exception(error_data jsonb)
       RETURNS boolean
       LANGUAGE plpgsql
      AS $function$
        -- version: 1
      BEGIN
        -- Feel free to change this function to change Logidze behavior on exception.
        --
        -- Return `false` to raise exception or `true` to commit record changes.
        --
        -- `error_data` contains:
        --   - returned_sqlstate
        --   - message_text
        --   - pg_exception_detail
        --   - pg_exception_hint
        --   - pg_exception_context
        --   - schema_name
        --   - table_name
        -- Learn more about available keys:
        -- https://www.postgresql.org/docs/9.6/plpgsql-control-structures.html#PLPGSQL-EXCEPTION-DIAGNOSTICS-VALUES
        --

        return false;
      END;
      $function$
  SQL
  create_function :logidze_compact_history, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.logidze_compact_history(log_data jsonb, cutoff integer DEFAULT 1)
       RETURNS jsonb
       LANGUAGE plpgsql
      AS $function$
        -- version: 1
        DECLARE
          merged jsonb;
        BEGIN
          LOOP
            merged := jsonb_build_object(
              'ts',
              log_data#>'{h,1,ts}',
              'v',
              log_data#>'{h,1,v}',
              'c',
              (log_data#>'{h,0,c}') || (log_data#>'{h,1,c}')
            );

            IF (log_data#>'{h,1}' ? 'm') THEN
              merged := jsonb_set(merged, ARRAY['m'], log_data#>'{h,1,m}');
            END IF;

            log_data := jsonb_set(
              log_data,
              '{h}',
              jsonb_set(
                log_data->'h',
                '{1}',
                merged
              ) - 0
            );

            cutoff := cutoff - 1;

            EXIT WHEN cutoff <= 0;
          END LOOP;

          return log_data;
        END;
      $function$
  SQL
  create_function :logidze_filter_keys, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.logidze_filter_keys(obj jsonb, keys text[], include_columns boolean DEFAULT false)
       RETURNS jsonb
       LANGUAGE plpgsql
      AS $function$
        -- version: 1
        DECLARE
          res jsonb;
          key text;
        BEGIN
          res := '{}';

          IF include_columns THEN
            FOREACH key IN ARRAY keys
            LOOP
              IF obj ? key THEN
                res = jsonb_insert(res, ARRAY[key], obj->key);
              END IF;
            END LOOP;
          ELSE
            res = obj;
            FOREACH key IN ARRAY keys
            LOOP
              res = res - key;
            END LOOP;
          END IF;

          RETURN res;
        END;
      $function$
  SQL
  create_function :logidze_logger, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.logidze_logger()
       RETURNS trigger
       LANGUAGE plpgsql
      AS $function$
        -- version: 5
        DECLARE
          changes jsonb;
          version jsonb;
          full_snapshot boolean;
          log_data jsonb;
          new_v integer;
          size integer;
          history_limit integer;
          debounce_time integer;
          current_version integer;
          k text;
          iterator integer;
          item record;
          columns text[];
          include_columns boolean;
          detached_log_data jsonb;
          -- We use `detached_loggable_type` for:
          -- 1. Checking if current implementation is `--detached` (`log_data` is stored in a separated table)
          -- 2. If implementation is `--detached` then we use detached_loggable_type to determine
          --    to which table current `log_data` record belongs
          detached_loggable_type text;
          log_data_table_name text;
          log_data_is_empty boolean;
          log_data_ts_key_data text;
          ts timestamp with time zone;
          ts_column text;
          err_sqlstate text;
          err_message text;
          err_detail text;
          err_hint text;
          err_context text;
          err_table_name text;
          err_schema_name text;
          err_jsonb jsonb;
          err_captured boolean;
        BEGIN
          ts_column := NULLIF(TG_ARGV[1], 'null');
          columns := NULLIF(TG_ARGV[2], 'null');
          include_columns := NULLIF(TG_ARGV[3], 'null');
          detached_loggable_type := NULLIF(TG_ARGV[5], 'null');
          log_data_table_name := NULLIF(TG_ARGV[6], 'null');

          -- getting previous log_data if it exists for detached `log_data` storage variant
          IF detached_loggable_type IS NOT NULL
          THEN
            EXECUTE format(
              'SELECT ldtn.log_data ' ||
              'FROM %I ldtn ' ||
              'WHERE ldtn.loggable_type = $1 ' ||
                'AND ldtn.loggable_id = $2 '  ||
              'LIMIT 1',
              log_data_table_name
            ) USING detached_loggable_type, NEW.id INTO detached_log_data;
          END IF;

          IF detached_loggable_type IS NULL
          THEN
              log_data_is_empty = NEW.log_data is NULL OR NEW.log_data = '{}'::jsonb;
          ELSE
              log_data_is_empty = detached_log_data IS NULL OR detached_log_data = '{}'::jsonb;
          END IF;

          IF log_data_is_empty
          THEN
            IF columns IS NOT NULL THEN
              log_data = logidze_snapshot(to_jsonb(NEW.*), ts_column, columns, include_columns);
            ELSE
              log_data = logidze_snapshot(to_jsonb(NEW.*), ts_column);
            END IF;

            IF log_data#>>'{h, -1, c}' != '{}' THEN
              IF detached_loggable_type IS NULL
              THEN
                NEW.log_data := log_data;
              ELSE
                EXECUTE format(
                  'INSERT INTO %I(log_data, loggable_type, loggable_id) ' ||
                  'VALUES ($1, $2, $3);',
                  log_data_table_name
                ) USING log_data, detached_loggable_type, NEW.id;
              END IF;
            END IF;

          ELSE

            IF TG_OP = 'UPDATE' AND (to_jsonb(NEW.*) = to_jsonb(OLD.*)) THEN
              RETURN NEW; -- pass
            END IF;

            history_limit := NULLIF(TG_ARGV[0], 'null');
            debounce_time := NULLIF(TG_ARGV[4], 'null');

            IF detached_loggable_type IS NULL
            THEN
                log_data := NEW.log_data;
            ELSE
                log_data := detached_log_data;
            END IF;

            current_version := (log_data->>'v')::int;

            IF ts_column IS NULL THEN
              ts := statement_timestamp();
            ELSEIF TG_OP = 'UPDATE' THEN
              ts := (to_jsonb(NEW.*) ->> ts_column)::timestamp with time zone;
              IF ts IS NULL OR ts = (to_jsonb(OLD.*) ->> ts_column)::timestamp with time zone THEN
                ts := statement_timestamp();
              END IF;
            ELSEIF TG_OP = 'INSERT' THEN
              ts := (to_jsonb(NEW.*) ->> ts_column)::timestamp with time zone;

              IF detached_loggable_type IS NULL
              THEN
                log_data_ts_key_data = NEW.log_data #>> '{h,-1,ts}';
              ELSE
                log_data_ts_key_data = detached_log_data #>> '{h,-1,ts}';
              END IF;

              IF ts IS NULL OR (extract(epoch from ts) * 1000)::bigint = log_data_ts_key_data::bigint THEN
                  ts := statement_timestamp();
              END IF;
            END IF;

            full_snapshot := (coalesce(current_setting('logidze.full_snapshot', true), '') = 'on') OR (TG_OP = 'INSERT');

            IF current_version < (log_data#>>'{h,-1,v}')::int THEN
              iterator := 0;
              FOR item in SELECT * FROM jsonb_array_elements(log_data->'h')
              LOOP
                IF (item.value->>'v')::int > current_version THEN
                  log_data := jsonb_set(
                    log_data,
                    '{h}',
                    (log_data->'h') - iterator
                  );
                END IF;
                iterator := iterator + 1;
              END LOOP;
            END IF;

            changes := '{}';

            IF full_snapshot THEN
              BEGIN
                changes = hstore_to_jsonb_loose(hstore(NEW.*));
              EXCEPTION
                WHEN NUMERIC_VALUE_OUT_OF_RANGE THEN
                  changes = row_to_json(NEW.*)::jsonb;
                  FOR k IN (SELECT key FROM jsonb_each(changes))
                  LOOP
                    IF jsonb_typeof(changes->k) = 'object' THEN
                      changes = jsonb_set(changes, ARRAY[k], to_jsonb(changes->>k));
                    END IF;
                  END LOOP;
              END;
            ELSE
              BEGIN
                changes = hstore_to_jsonb_loose(
                      hstore(NEW.*) - hstore(OLD.*)
                  );
              EXCEPTION
                WHEN NUMERIC_VALUE_OUT_OF_RANGE THEN
                  changes = (SELECT
                    COALESCE(json_object_agg(key, value), '{}')::jsonb
                    FROM
                    jsonb_each(row_to_json(NEW.*)::jsonb)
                    WHERE NOT jsonb_build_object(key, value) <@ row_to_json(OLD.*)::jsonb);
                  FOR k IN (SELECT key FROM jsonb_each(changes))
                  LOOP
                    IF jsonb_typeof(changes->k) = 'object' THEN
                      changes = jsonb_set(changes, ARRAY[k], to_jsonb(changes->>k));
                    END IF;
                  END LOOP;
              END;
            END IF;

            -- We store `log_data` in a separate table for the `detached` mode
            -- So we remove `log_data` only when we store historic data in the record's origin table
            IF detached_loggable_type IS NULL
            THEN
                changes = changes - 'log_data';
            END IF;

            IF columns IS NOT NULL THEN
              changes = logidze_filter_keys(changes, columns, include_columns);
            END IF;

            IF changes = '{}' THEN
              RETURN NEW; -- pass
            END IF;

            new_v := (log_data#>>'{h,-1,v}')::int + 1;

            size := jsonb_array_length(log_data->'h');
            version := logidze_version(new_v, changes, ts);

            IF (
              debounce_time IS NOT NULL AND
              (version->>'ts')::bigint - (log_data#>'{h,-1,ts}')::text::bigint <= debounce_time
            ) THEN
              -- merge new version with the previous one
              new_v := (log_data#>>'{h,-1,v}')::int;
              version := logidze_version(new_v, (log_data#>'{h,-1,c}')::jsonb || changes, ts);
              -- remove the previous version from log
              log_data := jsonb_set(
                log_data,
                '{h}',
                (log_data->'h') - (size - 1)
              );
            END IF;

            log_data := jsonb_set(
              log_data,
              ARRAY['h', size::text],
              version,
              true
            );

            log_data := jsonb_set(
              log_data,
              '{v}',
              to_jsonb(new_v)
            );

            IF history_limit IS NOT NULL AND history_limit <= size THEN
              log_data := logidze_compact_history(log_data, size - history_limit + 1);
            END IF;

            IF detached_loggable_type IS NULL
            THEN
              NEW.log_data := log_data;
            ELSE
              detached_log_data = log_data;
              EXECUTE format(
                'UPDATE %I ' ||
                'SET log_data = $1 ' ||
                'WHERE %I.loggable_type = $2 ' ||
                'AND %I.loggable_id = $3',
                log_data_table_name,
                log_data_table_name,
                log_data_table_name
              ) USING detached_log_data, detached_loggable_type, NEW.id;
            END IF;
          END IF;

          RETURN NEW; -- result
        EXCEPTION
          WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS err_sqlstate = RETURNED_SQLSTATE,
                                    err_message = MESSAGE_TEXT,
                                    err_detail = PG_EXCEPTION_DETAIL,
                                    err_hint = PG_EXCEPTION_HINT,
                                    err_context = PG_EXCEPTION_CONTEXT,
                                    err_schema_name = SCHEMA_NAME,
                                    err_table_name = TABLE_NAME;
            err_jsonb := jsonb_build_object(
              'returned_sqlstate', err_sqlstate,
              'message_text', err_message,
              'pg_exception_detail', err_detail,
              'pg_exception_hint', err_hint,
              'pg_exception_context', err_context,
              'schema_name', err_schema_name,
              'table_name', err_table_name
            );
            err_captured = logidze_capture_exception(err_jsonb);
            IF err_captured THEN
              return NEW;
            ELSE
              RAISE;
            END IF;
        END;
      $function$
  SQL
  create_function :logidze_logger_after, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.logidze_logger_after()
       RETURNS trigger
       LANGUAGE plpgsql
      AS $function$
        -- version: 5


        DECLARE
          changes jsonb;
          version jsonb;
          full_snapshot boolean;
          log_data jsonb;
          new_v integer;
          size integer;
          history_limit integer;
          debounce_time integer;
          current_version integer;
          k text;
          iterator integer;
          item record;
          columns text[];
          include_columns boolean;
          detached_log_data jsonb;
          -- We use `detached_loggable_type` for:
          -- 1. Checking if current implementation is `--detached` (`log_data` is stored in a separated table)
          -- 2. If implementation is `--detached` then we use detached_loggable_type to determine
          --    to which table current `log_data` record belongs
          detached_loggable_type text;
          log_data_table_name text;
          log_data_is_empty boolean;
          log_data_ts_key_data text;
          ts timestamp with time zone;
          ts_column text;
          err_sqlstate text;
          err_message text;
          err_detail text;
          err_hint text;
          err_context text;
          err_table_name text;
          err_schema_name text;
          err_jsonb jsonb;
          err_captured boolean;
        BEGIN
          ts_column := NULLIF(TG_ARGV[1], 'null');
          columns := NULLIF(TG_ARGV[2], 'null');
          include_columns := NULLIF(TG_ARGV[3], 'null');
          detached_loggable_type := NULLIF(TG_ARGV[5], 'null');
          log_data_table_name := NULLIF(TG_ARGV[6], 'null');

          -- getting previous log_data if it exists for detached `log_data` storage variant
          IF detached_loggable_type IS NOT NULL
          THEN
            EXECUTE format(
              'SELECT ldtn.log_data ' ||
              'FROM %I ldtn ' ||
              'WHERE ldtn.loggable_type = $1 ' ||
                'AND ldtn.loggable_id = $2 '  ||
              'LIMIT 1',
              log_data_table_name
            ) USING detached_loggable_type, NEW.id INTO detached_log_data;
          END IF;

          IF detached_loggable_type IS NULL
          THEN
              log_data_is_empty = NEW.log_data is NULL OR NEW.log_data = '{}'::jsonb;
          ELSE
              log_data_is_empty = detached_log_data IS NULL OR detached_log_data = '{}'::jsonb;
          END IF;

          IF log_data_is_empty
          THEN
            IF columns IS NOT NULL THEN
              log_data = logidze_snapshot(to_jsonb(NEW.*), ts_column, columns, include_columns);
            ELSE
              log_data = logidze_snapshot(to_jsonb(NEW.*), ts_column);
            END IF;

            IF log_data#>>'{h, -1, c}' != '{}' THEN
              IF detached_loggable_type IS NULL
              THEN
                NEW.log_data := log_data;
              ELSE
                EXECUTE format(
                  'INSERT INTO %I(log_data, loggable_type, loggable_id) ' ||
                  'VALUES ($1, $2, $3);',
                  log_data_table_name
                ) USING log_data, detached_loggable_type, NEW.id;
              END IF;
            END IF;

          ELSE

            IF TG_OP = 'UPDATE' AND (to_jsonb(NEW.*) = to_jsonb(OLD.*)) THEN
              RETURN NULL;
            END IF;

            history_limit := NULLIF(TG_ARGV[0], 'null');
            debounce_time := NULLIF(TG_ARGV[4], 'null');

            IF detached_loggable_type IS NULL
            THEN
                log_data := NEW.log_data;
            ELSE
                log_data := detached_log_data;
            END IF;

            current_version := (log_data->>'v')::int;

            IF ts_column IS NULL THEN
              ts := statement_timestamp();
            ELSEIF TG_OP = 'UPDATE' THEN
              ts := (to_jsonb(NEW.*) ->> ts_column)::timestamp with time zone;
              IF ts IS NULL OR ts = (to_jsonb(OLD.*) ->> ts_column)::timestamp with time zone THEN
                ts := statement_timestamp();
              END IF;
            ELSEIF TG_OP = 'INSERT' THEN
              ts := (to_jsonb(NEW.*) ->> ts_column)::timestamp with time zone;

              IF detached_loggable_type IS NULL
              THEN
                log_data_ts_key_data = NEW.log_data #>> '{h,-1,ts}';
              ELSE
                log_data_ts_key_data = detached_log_data #>> '{h,-1,ts}';
              END IF;

              IF ts IS NULL OR (extract(epoch from ts) * 1000)::bigint = log_data_ts_key_data::bigint THEN
                  ts := statement_timestamp();
              END IF;
            END IF;

            full_snapshot := (coalesce(current_setting('logidze.full_snapshot', true), '') = 'on') OR (TG_OP = 'INSERT');

            IF current_version < (log_data#>>'{h,-1,v}')::int THEN
              iterator := 0;
              FOR item in SELECT * FROM jsonb_array_elements(log_data->'h')
              LOOP
                IF (item.value->>'v')::int > current_version THEN
                  log_data := jsonb_set(
                    log_data,
                    '{h}',
                    (log_data->'h') - iterator
                  );
                END IF;
                iterator := iterator + 1;
              END LOOP;
            END IF;

            changes := '{}';

            IF full_snapshot THEN
              BEGIN
                changes = hstore_to_jsonb_loose(hstore(NEW.*));
              EXCEPTION
                WHEN NUMERIC_VALUE_OUT_OF_RANGE THEN
                  changes = row_to_json(NEW.*)::jsonb;
                  FOR k IN (SELECT key FROM jsonb_each(changes))
                  LOOP
                    IF jsonb_typeof(changes->k) = 'object' THEN
                      changes = jsonb_set(changes, ARRAY[k], to_jsonb(changes->>k));
                    END IF;
                  END LOOP;
              END;
            ELSE
              BEGIN
                changes = hstore_to_jsonb_loose(
                      hstore(NEW.*) - hstore(OLD.*)
                  );
              EXCEPTION
                WHEN NUMERIC_VALUE_OUT_OF_RANGE THEN
                  changes = (SELECT
                    COALESCE(json_object_agg(key, value), '{}')::jsonb
                    FROM
                    jsonb_each(row_to_json(NEW.*)::jsonb)
                    WHERE NOT jsonb_build_object(key, value) <@ row_to_json(OLD.*)::jsonb);
                  FOR k IN (SELECT key FROM jsonb_each(changes))
                  LOOP
                    IF jsonb_typeof(changes->k) = 'object' THEN
                      changes = jsonb_set(changes, ARRAY[k], to_jsonb(changes->>k));
                    END IF;
                  END LOOP;
              END;
            END IF;

            -- We store `log_data` in a separate table for the `detached` mode
            -- So we remove `log_data` only when we store historic data in the record's origin table
            IF detached_loggable_type IS NULL
            THEN
                changes = changes - 'log_data';
            END IF;

            IF columns IS NOT NULL THEN
              changes = logidze_filter_keys(changes, columns, include_columns);
            END IF;

            IF changes = '{}' THEN
              RETURN NULL;
            END IF;

            new_v := (log_data#>>'{h,-1,v}')::int + 1;

            size := jsonb_array_length(log_data->'h');
            version := logidze_version(new_v, changes, ts);

            IF (
              debounce_time IS NOT NULL AND
              (version->>'ts')::bigint - (log_data#>'{h,-1,ts}')::text::bigint <= debounce_time
            ) THEN
              -- merge new version with the previous one
              new_v := (log_data#>>'{h,-1,v}')::int;
              version := logidze_version(new_v, (log_data#>'{h,-1,c}')::jsonb || changes, ts);
              -- remove the previous version from log
              log_data := jsonb_set(
                log_data,
                '{h}',
                (log_data->'h') - (size - 1)
              );
            END IF;

            log_data := jsonb_set(
              log_data,
              ARRAY['h', size::text],
              version,
              true
            );

            log_data := jsonb_set(
              log_data,
              '{v}',
              to_jsonb(new_v)
            );

            IF history_limit IS NOT NULL AND history_limit <= size THEN
              log_data := logidze_compact_history(log_data, size - history_limit + 1);
            END IF;

            IF detached_loggable_type IS NULL
            THEN
              NEW.log_data := log_data;
            ELSE
              detached_log_data = log_data;
              EXECUTE format(
                'UPDATE %I ' ||
                'SET log_data = $1 ' ||
                'WHERE %I.loggable_type = $2 ' ||
                'AND %I.loggable_id = $3',
                log_data_table_name,
                log_data_table_name,
                log_data_table_name
              ) USING detached_log_data, detached_loggable_type, NEW.id;
            END IF;
          END IF;

          IF detached_loggable_type IS NULL
          THEN
            EXECUTE format('UPDATE %I.%I SET "log_data" = $1 WHERE ctid = %L', TG_TABLE_SCHEMA, TG_TABLE_NAME, NEW.CTID) USING NEW.log_data;
          END IF;

          RETURN NULL;

        EXCEPTION
          WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS err_sqlstate = RETURNED_SQLSTATE,
                                    err_message = MESSAGE_TEXT,
                                    err_detail = PG_EXCEPTION_DETAIL,
                                    err_hint = PG_EXCEPTION_HINT,
                                    err_context = PG_EXCEPTION_CONTEXT,
                                    err_schema_name = SCHEMA_NAME,
                                    err_table_name = TABLE_NAME;
            err_jsonb := jsonb_build_object(
              'returned_sqlstate', err_sqlstate,
              'message_text', err_message,
              'pg_exception_detail', err_detail,
              'pg_exception_hint', err_hint,
              'pg_exception_context', err_context,
              'schema_name', err_schema_name,
              'table_name', err_table_name
            );
            err_captured = logidze_capture_exception(err_jsonb);
            IF err_captured THEN
              return NEW;
            ELSE
              RAISE;
            END IF;
        END;
      $function$
  SQL
  create_function :logidze_snapshot, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.logidze_snapshot(item jsonb, ts_column text DEFAULT NULL::text, columns text[] DEFAULT NULL::text[], include_columns boolean DEFAULT false)
       RETURNS jsonb
       LANGUAGE plpgsql
      AS $function$
        -- version: 3
        DECLARE
          ts timestamp with time zone;
          k text;
        BEGIN
          item = item - 'log_data';
          IF ts_column IS NULL THEN
            ts := statement_timestamp();
          ELSE
            ts := coalesce((item->>ts_column)::timestamp with time zone, statement_timestamp());
          END IF;

          IF columns IS NOT NULL THEN
            item := logidze_filter_keys(item, columns, include_columns);
          END IF;

          FOR k IN (SELECT key FROM jsonb_each(item))
          LOOP
            IF jsonb_typeof(item->k) = 'object' THEN
               item := jsonb_set(item, ARRAY[k], to_jsonb(item->>k));
            END IF;
          END LOOP;

          return json_build_object(
            'v', 1,
            'h', jsonb_build_array(
                    logidze_version(1, item, ts)
                  )
            );
        END;
      $function$
  SQL
  create_function :logidze_version, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.logidze_version(v bigint, data jsonb, ts timestamp with time zone)
       RETURNS jsonb
       LANGUAGE plpgsql
      AS $function$
        -- version: 2
        DECLARE
          buf jsonb;
        BEGIN
          data = data - 'log_data';
          buf := jsonb_build_object(
                    'ts',
                    (extract(epoch from ts) * 1000)::bigint,
                    'v',
                    v,
                    'c',
                    data
                    );
          IF coalesce(current_setting('logidze.meta', true), '') <> '' THEN
            buf := jsonb_insert(buf, '{m}', current_setting('logidze.meta')::jsonb);
          END IF;
          RETURN buf;
        END;
      $function$
  SQL


  create_trigger :logidze_on_emails, sql_definition: <<-SQL
      CREATE TRIGGER logidze_on_emails BEFORE INSERT OR UPDATE ON public.emails FOR EACH ROW WHEN ((COALESCE(current_setting('logidze.disabled'::text, true), ''::text) <> 'on'::text)) EXECUTE FUNCTION logidze_logger('null', 'updated_at')
  SQL
  create_trigger :logidze_on_users, sql_definition: <<-SQL
      CREATE TRIGGER logidze_on_users BEFORE INSERT OR UPDATE ON public.users FOR EACH ROW WHEN ((COALESCE(current_setting('logidze.disabled'::text, true), ''::text) <> 'on'::text)) EXECUTE FUNCTION logidze_logger('null', 'updated_at')
  SQL
end
