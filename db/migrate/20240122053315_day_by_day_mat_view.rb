class DayByDayMatView < ActiveRecord::Migration[7.1]
  def change
    # execute "CREATE MATERIALIZED VIEW day_by_day AS
    #   SELECT
    #       time_bucket('1 day', datetime, 'America/Los_Angeles') AS datetime,
    #       SUM(enphase) AS enphase,
    #       SUM(from_sce) AS from_sce,
    #       SUM(to_sce) AS to_sce,
    #       SUM(enphase + from_sce - to_sce) AS used
    #   FROM energies
    #   GROUP BY
    #       time_bucket('1 day', datetime, 'America/Los_Angeles');
    # "
  end
end

# This worked and is the one used to create the Materialized View

# In TimescaleDB, continuous aggregates require a specific structure to maintain efficiency. The time bucket function in the SELECT clause needs to match the time bucket function specified in the GROUP BY clause.
# 
# The time bucket function in the SELECT clause is consistent with the one in the GROUP BY clause.
# The '12 hour' offset has been removed from the SELECT clause as it's not needed in this case.