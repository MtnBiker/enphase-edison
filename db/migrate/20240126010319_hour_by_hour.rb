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
      GROUP BYbin/rails db:migrate VERSION=20080906120000 time_bucket('1 hour', datetime, 'America/Los_Angeles')
      ORDER BY datetime;
    "
  end
end

# The following was done in PGAdmin
connection.execute(<<EOSQL)
  CREATE FUNCTION refresh_hour_by_hour()
  RETURNS trigger AS $function$
    BEGIN
      REFRESH MATERIALIZED VIEW hour_by_hour;
      RETURN NULL;
    END;
  $function$ LANGUAGE plpgsql;
EOSQL