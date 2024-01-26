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

ActiveRecord::Schema[7.1].define(version: 2024_01_26_032254) do
  create_schema "_timescaledb_cache"
  create_schema "_timescaledb_catalog"
  create_schema "_timescaledb_config"
  create_schema "_timescaledb_functions"
  create_schema "_timescaledb_internal"
  create_schema "timescaledb_experimental"
  create_schema "timescaledb_information"
  create_schema "toolkit_experimental"

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "timescaledb"
  enable_extension "timescaledb_toolkit"

  create_table "energies", primary_key: "datetime", id: :timestamptz, force: :cascade do |t|
    t.float "enphase"
    t.float "from_sce"
    t.float "to_sce"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end


  create_view "hour_by_hour", materialized: true, sql_definition: <<-SQL
      SELECT time_bucket('PT1H'::interval, datetime, 'America/Los_Angeles'::text) AS datetime,
      sum(enphase) AS enphase,
      sum(from_sce) AS from_sce,
      sum(to_sce) AS to_sce,
      sum(((enphase + from_sce) - to_sce)) AS used
     FROM energies
    GROUP BY (time_bucket('PT1H'::interval, datetime, 'America/Los_Angeles'::text))
    ORDER BY (time_bucket('PT1H'::interval, datetime, 'America/Los_Angeles'::text));
  SQL
  create_view "month_by_months", materialized: true, sql_definition: <<-SQL
      SELECT time_bucket('P1M'::interval, datetime, 'America/Los_Angeles'::text) AS datetime,
      sum(enphase) AS enphase,
      sum(from_sce) AS from_sce,
      sum(to_sce) AS to_sce,
      sum(((enphase + from_sce) - to_sce)) AS used
     FROM energies
    GROUP BY (time_bucket('P1M'::interval, datetime, 'America/Los_Angeles'::text))
    ORDER BY (time_bucket('P1M'::interval, datetime, 'America/Los_Angeles'::text));
  SQL
  create_view "day_by_days", materialized: true, sql_definition: <<-SQL
      SELECT time_bucket('P1D'::interval, datetime, 'America/Los_Angeles'::text) AS datetime,
      sum(enphase) AS enphase,
      sum(from_sce) AS from_sce,
      sum(to_sce) AS to_sce,
      sum(((enphase + from_sce) - to_sce)) AS used
     FROM energies
    GROUP BY (time_bucket('P1D'::interval, datetime, 'America/Los_Angeles'::text))
    ORDER BY (time_bucket('P1D'::interval, datetime, 'America/Los_Angeles'::text));
  SQL
  create_view "hour_by_hours", materialized: true, sql_definition: <<-SQL
      SELECT time_bucket('PT1H'::interval, datetime, 'America/Los_Angeles'::text) AS datetime,
      sum(enphase) AS enphase,
      sum(from_sce) AS from_sce,
      sum(to_sce) AS to_sce,
      sum(((enphase + from_sce) - to_sce)) AS used
     FROM energies
    GROUP BY (time_bucket('PT1H'::interval, datetime, 'America/Los_Angeles'::text))
    ORDER BY (time_bucket('PT1H'::interval, datetime, 'America/Los_Angeles'::text));
  SQL
  create_hypertable "energies", time_column: "datetime", chunk_time_interval: "7 days", create_default_indexes: false
end
