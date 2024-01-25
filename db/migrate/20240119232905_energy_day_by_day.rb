class EnergyDayByDay < ActiveRecord::Migration[7.1]
  # def change
  #   execute "CREATE MATERIALIZED VIEW day_by_day(datetime, enphase, from_sce, to_sce)
  #   with (timescaledb.continuous) as
  #   SELECT time_bucket('5 min', time) + '5 min' AS bucket,
  #   SELECT time_bucket('1 day', datetime, 'America/Los_Angeles') + '12 hour' AS datetime, # datetime will be mid day
  #   SUM(enphase) AS enphase,
  #   SUM(from_sce) AS from_sce,
  #   SUM(to_sce) AS to_sce,
  #   (enphase + from_sce - to_sce) AS used
  #   FROM energies
  #   GROUP BY (1, energies.datetime);
  #   "
  # end
end

# Assuming the sum is over the time_bucket