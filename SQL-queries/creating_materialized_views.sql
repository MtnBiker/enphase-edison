-- https://docs.timescale.com/tutorials/latest/energy-data/dataset-energy/#create-continuous-aggregates
-- https://docs.timescale.com/tutorials/latest/energy-data/dataset-energy/#creating-continuous-aggregates-for-energy-consumption-by-day-and-hour
-- original
-- CREATE MATERIALIZED VIEW kwh_day_by_day(time, value)
--     with (timescaledb.continuous) as
-- SELECT time_bucket('1 day', created, 'Europe/Berlin') AS "time",
--         round((last(value, created) - first(value, created)) * 100.) / 100. AS value
-- FROM metrics
-- WHERE type_id = 5
-- GROUP BY 1;

CREATE MATERIALIZED VIEW wh_day_by_day_2(time, enphase, from_sce, to_sce)
    with (timescaledb.continuous) as
SELECT time_bucket('1 day', datetime, 'America/Los_Angeles') AS "datetime",
    last(enphase, datetime) - first(enphase, datetime) AS enphase,
    last(from_sce, datetime) - first(from_sce, datetime) AS from_sce,
    last(to_sce, datetime) - first(to_sce, datetime) AS to_sce
FROM energies
GROUP BY 1;

NOTICE:  refreshing continuous aggregate "wh_day_by_day_2"
CREATE MATERIALIZED VIEW

but where is it? In "Views" not "Materialized Views"
All four columns
But Only got from_sce data, enphase and to_sce are 0 
Drop Materialized View wh_day_by_day_2;
Then ran again with datetime

CREATE MATERIALIZED VIEW wh_day_by_day_2(datetime, enphase, from_sce, to_sce)
    with (timescaledb.continuous) as
SELECT time_bucket('1 day', datetime, 'America/Los_Angeles') AS "datetime",
    last(enphase, datetime) - first(enphase, datetime) AS enphase,
    last(from_sce, datetime) - first(from_sce, datetime) AS from_sce,
    last(to_sce, datetime) - first(to_sce, datetime) AS to_sce
FROM energies
GROUP BY 1;
-- still only data in from_sce

-- without from_sce since was getting that
-- Drop Materialized View wh_day_by_day_2;
CREATE MATERIALIZED VIEW wh_day_by_day_2(datetime, enphase, to_sce)
    with (timescaledb.continuous) as
SELECT time_bucket('1 day', datetime, 'America/Los_Angeles') AS "datetime",
    last(enphase, datetime) - first(enphase, datetime) AS enphase,
    last(to_sce, datetime) - first(to_sce, datetime) AS to_sce
FROM energies
GROUP BY 1;
-- all 0s


CREATE MATERIALIZED VIEW wh_day_by_day_2(datetime, enphase, to_sce)
    with (timescaledb.continuous) as
SELECT time_bucket('1 day', datetime, 'America/Los_Angeles') AS "datetime",
    round((last(enphase, datetime) - first(enphase, datetime)) * 100.) / 100. AS enphase,
    last(to_sce, datetime) - first(to_sce, datetime) AS to_sce
FROM energies
GROUP BY 1;
-- changing to round etc didn't help, still all 0s