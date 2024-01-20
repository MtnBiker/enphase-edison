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

ActiveRecord::Schema[7.1].define(version: 2024_01_20_052303) do
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

  create_table "wh_day_by_days", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_hypertable "energies", time_column: "datetime", chunk_time_interval: "7 days", create_default_indexes: false
  create_continuous_aggregate("wh_day_by_day", <<-SQL, refresh_policies: { start_offset: "NULL", end_offset: "INTERVAL 'PT1H'", schedule_interval: "INTERVAL '3600'"})
    SELECT time_bucket('P1D'::interval, datetime, 'America/Los_Angeles'::text) AS datetime,
      enphase,
      from_sce,
      to_sce,
      ((enphase + from_sce) - to_sce) AS used
     FROM energies
    GROUP BY (time_bucket('P1D'::interval, datetime, 'America/Los_Angeles'::text)), datetime
  SQL

  create_continuous_aggregate("wh_day_by_day_all", <<-SQL, refresh_policies: { start_offset: "NULL", end_offset: "INTERVAL '01:00:00'", schedule_interval: "INTERVAL '3600'"})
    SELECT time_bucket('P1D'::interval, datetime, 'America/Los_Angeles'::text) AS "time",
      (last(enphase, datetime) - first(enphase, datetime)) AS enphase,
      (last(from_sce, datetime) - first(from_sce, datetime)) AS from_sce,
      (last(to_sce, datetime) - first(to_sce, datetime)) AS to_sce
     FROM energies
    GROUP BY (time_bucket('P1D'::interval, datetime, 'America/Los_Angeles'::text))
  SQL

end
