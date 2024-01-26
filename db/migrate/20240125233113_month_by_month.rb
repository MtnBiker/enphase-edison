class MonthByMonth < ActiveRecord::Migration[7.1]
  def change
    execute "CREATE MATERIALIZED VIEW month_by_month AS
      SELECT
          time_bucket('1 month', datetime, 'America/Los_Angeles') AS datetime,
          SUM(enphase) AS enphase,
          SUM(from_sce) AS from_sce,
          SUM(to_sce) AS to_sce,
          SUM(enphase + from_sce - to_sce) AS used
      FROM energies
      GROUP BY
          time_bucket('1 month', datetime, 'America/Los_Angeles')
      ORDER BY datetime;
      "
    end
end

connection.execute(<<EOSQL)
  CREATE FUNCTION refresh_month_by_month()
  RETURNS trigger AS $function$
    BEGIN
      REFRESH MATERIALIZED VIEW month_by_month;
      RETURN NULL;
    END;
  $function$ LANGUAGE plpgsql;
EOSQL

# Trigger the refresh function whenever the table changes
connection.execute(<<EOSQL)
  CREATE TRIGGER trigger_refresh_month_by_month_on_state_change
      AFTER UPDATE OF state OR DELETE OR TRUNCATE
      ON month_by_month FOR EACH STATEMENT
      EXECUTE PROCEDURE refresh_month_by_month();
EOSQL
