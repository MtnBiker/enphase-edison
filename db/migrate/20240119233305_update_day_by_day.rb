class UpdateDayByDay < ActiveRecord::Migration[7.1]
  def change
    execute "  SELECT add_continuous_aggregate_policy('day_by_day',
    start_offset => NULL,
    end_offset => INTERVAL '1 hour',
    schedule_interval => INTERVAL '1 hour');
    "
  end
end
# https://docs.timescale.com/tutorials/latest/energy-data/dataset-energy/create-continuous-aggregates
# Actually did in PGAdmin