class DayByDaySort < ActiveRecord::Migration[7.1]
 def change
    # execute "CREATE MATERIALIZED VIEW day_by_day_sort AS
    #   SELECT
    #       time_bucket('1 day', datetime, 'America/Los_Angeles') AS datetime,
    #       SUM(enphase) AS enphase,
    #       SUM(from_sce) AS from_sce,
    #       SUM(to_sce) AS to_sce,
    #       SUM(enphase + from_sce - to_sce) AS used
    #   FROM energies
    #   GROUP BY
    #       time_bucket('1 day', datetime, 'America/Los_Angeles')
    #   ORDER BY datetime;
    # "
  end
end

# Used a test