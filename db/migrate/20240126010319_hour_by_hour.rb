class HourByHour < ActiveRecord::Migration[7.1]
  def change
    execute "CREATE MATERIALIZED VIEW hour_by_hour AS
      SELECT
          time_bucket('1 hour', datetime, 'America/Los_Angeles') AS datetime,
          SUM(enphase) AS enphase,
          SUM(from_sce) AS from_sce,
          SUM(to_sce) AS to_sce,
          SUM(enphase + from_sce - to_sce) AS used
      FROM energies
      GROUP BY time_bucket('1 hour', datetime, 'America/Los_Angeles')
      ORDER BY datetime;
    "
  end
end
Later did over in scenic