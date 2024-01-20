class EnergyView < ActiveRecord::Migration[7.1]
  def change
    execute "CREATE MATERIALIZED VIEW day_by_day
    with (timescaledb.continuous) as
    SELECT time_bucket('1 day', datetime, 'America/Los_Angeles') AS datetime,
    enphase AS enphase,
    from_sce AS from_sce,
    to_sce AS to_sce,
    (enphase + from_sce - to_sce) AS used
    FROM energies
    GROUP BY (1, energies.enphase, energies.from_sce, energies.to_sce);
    "
  end
end

# This finally worked in PGAdmin