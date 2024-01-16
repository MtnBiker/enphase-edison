-- per month 
-- https://docs.timescale.com/tutorials/latest/energy-data/query-energy/#what-is-the-energy-consumption-on-a-monthly-basis
-- Don't be confused by the per_day!
--  kwh_day_by_day to wh_day_by_day
-- substitute value with enphase for first run
WITH per_day AS (
 SELECT
   time,
   enphase
 FROM wh_day_by_day_all
 WHERE "time" > now() - interval '1 year'
 ORDER BY 1
), per_month AS (
   SELECT
      to_char(time, 'Mon') as month,
       sum(enphase) as enphase
   FROM per_day
  GROUP BY 1
)
SELECT
   m.month,
--   m.ordinal,
   pd.enphase
FROM unnest(array['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']) WITH ORDINALITY AS m(month, ordinal)
LEFT JOIN per_month pd ON lower(pd.month) = lower(m.month)
ORDER BY ordinal;

-- As expected [null] for Jan thru Sept. But 0 for Oct, Nov, Dec
--try with from_sce
WITH per_day AS (
 SELECT
   time,
   from_sce
 FROM wh_day_by_day_all
 WHERE "time" > now() - interval '1 year'
 ORDER BY 1
), per_month AS (
   SELECT
      to_char(time, 'Mon') as month,
       sum(from_sce) as from_sce
   FROM per_day
  GROUP BY 1
)
SELECT
   m.month,
--   m.ordinal,
   pd.from_sce
FROM unnest(array['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']) WITH ORDINALITY AS m(month, ordinal)
LEFT JOIN per_month pd ON lower(pd.month) = lower(m.month)
ORDER BY ordinal;
-- Got results for each month but not sensible
