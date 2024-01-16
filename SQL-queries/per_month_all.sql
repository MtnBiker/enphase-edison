-- trying for all four columns
WITH per_day AS (
 SELECT
   time,
   enphase,
   from_sce,
   to_sce
 FROM wh_day_by_day_all
 WHERE "time" > now() - interval '1 year'
 ORDER BY 1
), per_month AS (
   SELECT
      to_char(time, 'Mon') as month,
      sum(enphase) as enphase,
      sum(from_sce) as from_sce,
      sum(to_sce) as to_sce
   FROM per_day
  GROUP BY 1
)
SELECT
   m.month,
--   m.ordinal,
  pd.enphase,
  pd.from_sce,
  pd.to_sce
FROM unnest(array['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']) WITH ORDINALITY AS m(month, ordinal)
LEFT JOIN per_month pd ON lower(pd.month) = lower(m.month)
ORDER BY ordinal;
-- Got results for each month but not sensible, now to take this to a webpage
