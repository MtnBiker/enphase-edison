WITH per_day AS (
 SELECT
   time,
   enphase
 FROM wh_day_by_day
 WHERE "time" at time zone 'America/Los_Angeles' > date_trunc('month', time) - interval '1 year'
 ORDER BY 1
), daily AS (
    SELECT
       to_char(time, 'Dy') as day,
       enphase
    FROM per_day
), percentile AS (
    SELECT
        day,
        approx_percentile(0.50, percentile_agg(enphase)) as enphase
    FROM daily
    GROUP BY 1
    ORDER BY 1
)
SELECT
    d.day,
    d.ordinal,
    pd.enphase
FROM unnest(array['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']) WITH ORDINALITY AS d(day, ordinal)
LEFT JOIN percentile pd ON lower(pd.day) = lower(d.day);

Runs, but all 7 enphase are 0

Looking at wh_day_by_day, enphase is either [null] or 0
=======
TODO get the data right, but first

wh_day_by_day_all has from_sce data, so  try 

WITH per_day AS (
 SELECT
   time,
   from_sce
 FROM wh_day_by_day_all
 WHERE "time" at time zone 'America/Los_Angeles' > date_trunc('month', time) - interval '1 year'
 ORDER BY 1
), daily AS (
    SELECT
       to_char(time, 'Dy') as day,
       from_sce
    FROM per_day
), percentile AS (
    SELECT
        day,
        approx_percentile(0.50, percentile_agg(from_sce)) as from_sce
    FROM daily
    GROUP BY 1
    ORDER BY 1
)
SELECT
    d.day,
    d.ordinal,
    pd.from_sce
FROM unnest(array['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']) WITH ORDINALITY AS d(day, ordinal)
LEFT JOIN percentile pd ON lower(pd.day) = lower(d.day);

Runs with enphase and same result
change enphase to from_sce

All 0 except Mon, so slightly right