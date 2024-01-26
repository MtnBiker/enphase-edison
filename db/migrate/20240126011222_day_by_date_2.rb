class DayByDate2 < ActiveRecord::Migration[7.1]
 def change
    execute "CREATE MATERIALIZED VIEW day_by_day AS
      SELECT
          time_bucket('1 day', datetime, 'America/Los_Angeles') AS datetime,
          SUM(enphase) AS enphase,
          SUM(from_sce) AS from_sce,
          SUM(to_sce) AS to_sce,
          SUM(enphase + from_sce - to_sce) AS used
      FROM energies
      GROUP BY time_bucket('1 day', datetime, 'America/Los_Angeles')
      ORDER BY datetime;
    "
  end
end

# Repeating as the original one wasn't sorted (ORDER)

The following was done in PGAdmin
connection.execute(<<EOSQL)
  CREATE FUNCTION refresh_day_by_day()
  RETURNS trigger AS $function$
    BEGIN
      REFRESH MATERIALIZED VIEW day_by_day;
      RETURN NULL;
    END;
  $function$ LANGUAGE plpgsql;
EOSQL