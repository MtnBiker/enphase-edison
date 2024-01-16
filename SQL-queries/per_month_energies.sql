-- direct from energies not hyper/materialized and wWh
WITH per_day AS (
 SELECT
   datetime,
   enphase,
   from_sce,
   to_sce
 FROM energies
 WHERE "datetime" > now() - interval '1 year'
 ORDER BY 1
), per_month AS (
   SELECT
      to_char(datetime, 'Mon') as month,
      sum(enphase)/1000 as enphase,
      sum(from_sce)/1000 as from_sce,
      sum(to_sce)/1000 as to_sce
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
-- Good results. One spot check was dead on.
