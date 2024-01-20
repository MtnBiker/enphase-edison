class EnergyDayByDay < ActiveRecord::Migration[7.1]
  def change
    # execute "CREATE MATERIALIZED VIEW day_by_day(datetime, enphase, from_sce, to_sce)
    # with (timescaledb.continuous) as
    # SELECT time_bucket('1 day', datetime, 'America/Los_Angeles'),
    # enphase AS enphase,
    # from_sce AS from_sce,
    # to_sce AS to_sce,
    # (enphase + from_sce - to_sce) AS used
    # FROM energies
    # GROUP BY (1, energies.datetime);
    # "
  end
end

# Was trying without NO DATA