class DayByDayMatView < ActiveRecord::Migration[7.1]
  def change
    execute "CREATE MATERIALIZED VIEW day_by_day AS
      SELECT
          time_bucket('1 day', datetime, 'America/Los_Angeles') AS datetime,
          SUM(enphase) AS enphase,
          SUM(from_sce) AS from_sce,
          SUM(to_sce) AS to_sce,
          SUM(enphase + from_sce - to_sce) AS used
      FROM energies
      GROUP BY
          time_bucket('1 day', datetime, 'America/Los_Angeles');
    "
  end
end

# CREATE MATERIALIZED VIEW day_by_day(datetime, enphase, from_sce, to_sce)
# with (timescaledb.continuous) as
# SELECT time_bucket('1 day', datetime, 'America/Los_Angeles') + '12 hour' AS datetime,
# SUM(enphase) AS enphase,
# SUM(from_sce) AS from_sce,
# SUM(to_sce) AS to_sce,
# (enphase + from_sce - to_sce) AS used
# FROM energies
# GROUP BY (1, energies.datetime, energies.enphase, energies.from_sce, energies.to_sce);
# 
# PG::ActiveSqlTransaction: ERROR:  CREATE MATERIALIZED VIEW ... WITH DATA cannot run inside a transaction block
# Same error with
# CREATE MATERIALIZED VIEW day_by_day(datetime, enphase, from_sce, to_sce)
# with (timescaledb.continuous) as
# SELECT time_bucket('1 day', datetime, 'America/Los_Angeles') + '12 hour' AS datetime,
# SUM(enphase) AS enphase,
# SUM(from_sce) AS from_sce,
# SUM(to_sce) AS to_sce,
# (enphase + from_sce - to_sce) AS used
# FROM energies
# GROUP BY ((time_bucket('1 day', datetime, 'America/Los_Angeles') + '12 hour' ), energies.datetime, energies.enphase, energies.from_sce, energies.to_sce)

# CREATE MATERIALIZED VIEW day_by_day(datetime, enphase, from_sce, to_sce)
# with (timescaledb.continuous) as
# SELECT time_bucket('1 day', datetime, 'America/Los_Angeles') + '12 hour' AS datetime,
# SUM(enphase) AS enphase,
# SUM(from_sce) AS from_sce,
# SUM(to_sce) AS to_sce,
# (enphase + from_sce - to_sce) AS used
# FROM energies
# GROUP BY (1, energies.datetime, energies.enphase, energies.from_sce, energies.to_sce);
# 
# PG::ActiveSqlTransaction: ERROR:  CREATE MATERIALIZED VIEW ... WITH DATA cannot run inside a transaction block
# Same error with
# CREATE MATERIALIZED VIEW day_by_day(datetime, enphase, from_sce, to_sce)
# with (timescaledb.continuous) as
# SELECT time_bucket('1 day', datetime, 'America/Los_Angeles') + '12 hour' AS datetime,
# SUM(enphase) AS enphase,
# SUM(from_sce) AS from_sce,
# SUM(to_sce) AS to_sce,
# (enphase + from_sce - to_sce) AS used
# FROM energies
# GROUP BY ((time_bucket('1 day', datetime, 'America/Los_Angeles') + '12 hour' ), energies.datetime, energies.enphase, energies.from_sce, energies.to_sce)
# Same error without + '12 hour'  in both place