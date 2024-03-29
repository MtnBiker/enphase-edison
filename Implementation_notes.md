Built on enphase2 app.
Put all data in one table
all date-time to datetime
renamed columns to fit that scheme. Might want to change those, usual problem of succinct but descriptive

➜ rails new solar_enphase_edison -j esbuild -a propshaft --css bootstrap --database postgresql --skip-action-mailer --skip-action-mailbox --skip-action-cable
Rails 7.1.2
ruby 3.3.0 (2023-12-25 revision 5124f9ac75) [arm64-darwin23]
v18.19.0
1.22.19
Bundler version 2.5.4
psql (PostgreSQL) 16.1

config/application.rb config.time_zone = "Pacific Time (US & Canada)"
SQL timezone is

Changed db from solar_enphase_edison to energy
➜ bin/rails db:create

rails generate scaffold energy datetime:timestamptz enphase:float from_sce:float to_sce:float

create_table :energies, id: false do |t|
t.timestamptz :datetime, null: false, primary_key: true
t.float :enphase
t.float :from_sce
t.float :to_sce

t.timestamps

rails new hadn't finished. A change to bin/dev. I created a new app to make sure I had the file right
➜ rdm
➜ gem install timescaledb # this doesn't get in the app, maybe bundle install timescaledb would
gem 'timescaledb'
bundle

### # do I need to CREATE EXTENSION IF NOT EXISTS timescaledb; -- in PGAdmin psql

Pagy: many bits

gem "solargraph" # For my installation, not for app

### See also Read-me

https://www.mattmorgante.com/technology/csv
and https://gorails.com/episodes/intro-to-importing-from-csv ~2015

Both Enphase and Edison are in 15 minute increments (which is handy, one less difference). Formatting is different (double quotes around info, times shown differently although both local (not UTC))

SCE data is local time (can tell by Received which is what SCE receives from us and the times line up with production)
SCE has a one hour time period, i.e., start and stop, energy delivered and energy received in kWh
Format of csv. First line which is midnight and SCE is delivering to Delicias
Energy  Delivered time period,Usage Delivered(Real energy in kilowatt-hours)(Real energy in kilowatt-hours),Reading quality
"2023-12-01 00:00:00 to 2023-12-01 00:15:00","0.070",""

Enphase
Date/Time,Energy Produced (Wh)
2023-11-01 00:00:00 -0700,0
Local time, but offset shown. I.e., this is midnight but showing TZ

Can import SCE with initial headers deleted, double quotes deleted and empty lines removed.

➜ yarn add chartkick # is this needed. Charts getting "Loading…" Needed to add import "chartkick/chart.js";
to app/javascript/application.js. Now graphs working.

Can import Enphase (without mod I think) and Edison with minimal mod.

All rows aren't showing. The data is in the database. Maybe an issue with Pagy. TODO if don't make tables with Timescale

### Timescale

https://github.com/timescale/timescaledb Using TimescaleDB
CREATE EXTENSION timescaledb; # success
and already have gem "timescaledb"
-- Then we convert it into a hypertable that is partitioned by time (may have to empty table to do this)

SELECT create_hypertable('conditions', by_range('time'), migrate_data = true); -- last to use existing data, syntax ??
SELECT create_hypertable('energies', by_range('datetime'), migrate_data = true); --
SELECT create_hypertable('energies', 'datetime'); -- (1,public,energies,t) after Truncating table energies
Reimported data (did Enphase first and Edison second as test of doing it in that order. Quick check it worked) BUT display order in app is weird. Not in descending order and that gaps in data. Wait for timescale though to see what's going on

from the github page
➜ tsdb "postgres://gscar@localhost:5432/energy_development" --stats ## got an error about pry

Used (or consumed) = enphase + from_sce - to_sce. All are expressed as positive in the original data. Order is what I'm standardizing on at the moment
Local time Produced From Sent to Used
12 Oct 2023 8:15 am 0 30 50 -20, but enphase didn't report any production until 8:30 and it was 8 Wh (0.030, 0.050 from SCE original)

From Create continuous aggregates https://docs.timescale.com/tutorials/latest/energy-data/dataset-energy/
From tutorial

Materialized Views. Usually used for speeding up pages, but for me it's about having easily identifiable tables

Updating:
SELECT add_continuous_aggregate_policy('wh_day_by_day',
start_offset => NULL,
end_offset => INTERVAL '1 hour',
schedule_interval => INTERVAL '1 hour');

---

Let's try for all variables. Could used be added? Calculations are done. What is the timezone doing here.
CREATE MATERIALIZED VIEW wh_day_by_day_all(time, enphase, from_sce, to_sce)
with (timescaledb.continuous) as
SELECT time_bucket('1 day', datetime, 'America/Los_Angeles') AS "datetime",
last(enphase, datetime) - first(enphase, datetime) AS enphase,
last(from_sce, datetime) - first(from_sce, datetime) AS from_sce,
last(to_sce, datetime) - first(to_sce, datetime) AS to_sce
FROM energies
GROUP BY 1;
-- Only from_sce is populated, the rest are null
and

-- Then we convert it into a hypertable that is partitioned by time
SELECT create_hypertable('conditions', 'time');

SELECT add_continuous_aggregate_policy('wh_day_by_day_all',
start_offset => NULL,
end_offset => INTERVAL '1 hour',
schedule_interval => INTERVAL '1 hour');

Only getting data for from_sce. Do I have a column naming error? I don't think so

SWAG to show table
➜ rails generate model wh_day_by_day_all # created a table wh_day_by_day_alls with (from memory since I rolled it back) datetime enphase, from_sce, and to_see with only the from_sce having any values. I think it picked up from the materialized view since the migration only had t.timestamp. But added a line to model
rails g controller wh_day_by_day_all index show

Added lots of pieces to try to get wh_day_by_day_all table to show--put in a stash

Why creating a materialized view for hypertable? What's the connection? Obviously they are similar in intent.

Tutorial goes into Grafana which seems to be used to track problems and performance. Do I need this? And it isn't available for pg16

CREATE EXTENSION timescaledb_toolkit;
ERROR: could not access file "MODULE_PATHNAME": No such file or directory # See below, got this working

So I started over using https://stackoverflow.com/questions/73248119/how-do-you-install-timescaledb-on-mac-os-m1-apple-silicone-if-you-have-the-pos which I saved in Notes.app and at the bottom of this page.

Now success:
energy_development=# CREATE EXTENSION timescaledb_toolkit;
CREATE EXTENSION

Tried a query from tutorial and got some result. So Timescale pieces are probably working, just the data and queries need help https://docs.timescale.com/tutorials/latest/energy-data/query-energy/#what-is-the-energy-consumption-by-the-day-of-the-week

Try https://docs.timescale.com/tutorials/latest/energy-data/query-energy/#what-is-the-energy-consumption-on-a-monthly-basis to see if can sort out why not gettng the right result for per day (day of the week)

SQL-queries/per_month_all.sql runs in PGAdmin but results don't make much sense, i.e., not accurate. Ah, the base data is wrong in wh_day_by_day_all. Not being updated or was created incorrectly.

##### Maybe go back to how the views are created. data in energies looks good.

Materialized view is created, then converted to hypertable. I think. Yes
To create a hypertable, you need to create a standard PostgreSQL table, and then convert it into a hypertable.

Hypertables are intended for time-series data, so your table needs a column that holds time values.

https://docs.timescale.com/quick-start/latest/ruby/#create-scopes-to-reuse
Energy.per_day.all in rails console with model change, but doen't work

## Energy.order("datetime").last # this works and doesn't rely on definitions in model, All fields shown

Energy.monthly_summary outputs in Nova/rc. Note that the output is not quite right yet. Doesn't work in iTerm
result = Energy.monthly_summary returns an object

Energy.monthly_summary.limit(10).offset(5) works in rc, but adding limit offset to monthly_summary does not, nor does used show up. At present 14 results show up in PGAdmin, so this command shows all the last ones

Finally got a migration to create day_by_day and it resulted in a Materialized View rather than a View. ChatGPT and persistence to the rescue

Setting up model for each mat view: https://medium.com/@rebo_dood/the-benefits-of-materialized-views-and-how-to-use-them-in-your-ruby-on-rails-project-4ac1b5432881

gem "scenic" seems like may solve some problems for me. https://github.com/scenic-views/scenic and https://raghu-bhupatiraju.dev/implementing-materialized-views-in-rails-ffea22bd5d9c

Got the three views sorted out. Requires a model for each, but much can be reused. Also the energy_controller knows about each one

Hourly for a day working. Had to give up (at least for now) on \_energy.html.erb for all three as datetime format needs to be different.
Tab not highlighting.

#### Datepicker

Bootstrap installed via --css bootstrap. Guess that's all the needed (many online tutorials etc make it harder)
app/javascript/application.js `import * as bootstrap from "bootstrap";`
ChatGPT You can use a separate datepicker library like flatpickr or datepicker. flatpickr assume JavaScript installation of old. simple_form instructions seem more up to date.
https://github.com/heartcombo/simple_form?tab=readme-ov-file#installation if go with simple_form

gem "simple_form"
➜ rails generate simple_form:install --bootstrap
Not sure I'm still using simple_form

If the approach I'm taking is right it makes sense to put the graph in a turbo
ChatGPT came up with a turbo solution. Doesn't seem like it's following the standard way, but it works.

#### Turbo Streams. Try on daily (hourly used ChatGPT with what seemed an odd implemention)

Turbo Streams introduces a <turbo-stream> element with seven basic actions: append, prepend, replace, update, remove, before, and after.

Simple Bootstrap navbar. Tried Tailwind. Was trying for navbar that would highlight current page. Seems to require crafted jS. Should be a Hotwire way?

2024.02.01 Materialized Views not auto updating or do I need to wait an hour? Or could I change to just Views. I don't think I need the performance benefit of a Materialized View
Try creating view_hours using Mat View as sample
What Are PostgreSQL Views? Why Should I Use Them? https://www.timescale.com/blog/how-postgresql-views-and-materialized-views-work-and-how-they-influenced-timescaledb-continuous-aggregates/
rgm CreateViewHours
rdm: No such file or directory @ rb_sysopen - /Users/gscar/Documents/Delicias/Utilities, Energy and Solar/Solar Panels 2023-ABC/Solar production, etc/solar_enphase_edison/db/views/view_hours_v01.sql > created and copied from hour_by_hours_v01.sql
Change HourByHours to ViewHours
Created model and controller and other changes. See commit

Now do same for daily and see if table updates when import Enphase data. I had imported Jan data for SCE, but not enphase so can't tell about updating. And monthly

Now only plain Views and not Materialized Views (Don't have to worry about updating. Materialized Views are for large DBs)

Importing working.

https://github.com/JackC/tod Time of Day gem for overlay plots?

Push to github. Set up on the site and follow this?
git remote add origin https://github.com/MtnBiker/enphase-edison.git
git push -u origin main
Worked. Note app name is different than my local name.

Added select dates for overlay hourly

Removed SQL-queries from GitHub. Had added to .gitignore, but had already committed them

## ToDo

Arrow day by day next to select a day

15 minute intervals for daily

Overlays: \_hourly_day_vs_day.html.erb. Move logic off page. Detect end of day instead of hardwiring.

Record of data loading/importing-create table and at line at top

Graphs of totals per day: For selectable time periods. Jan 5 to jan 25 e.g. Some present such as last year. Last month. Last 12 months And select received Del used etc

Table sorting (now ascending by datetime). Pagy

Get rid of manual changes for importing

Format of change dates for overlay chart needs help

The following two aren't being used, but aren't adding much. Just want to make sure not being used
Remove Tailwind gem
Remove simple_forms gem

### Some Timescaledb installation notes. Add any new items above this. Meant to be more like a footnote

/usr/bin/install -c -m 755 $(find /opt/homebrew/Cellar/timescaledb/2.13.1/lib/timescaledb/postgresql/ -name "timescaledb\*.so") /Applications/Postgres.app/Contents/Versions/16/lib/postgresql

/usr/bin/install -c -m 644 /opt/homebrew/Cellar/timescaledb/2.7.2/share/timescaledb/\* /Applications/Postgres.app/Contents/Versions/14/share/postgresql/extension/

➜ timescaledb-tune --yes --conf-path="/Users/gscar/Library/Application Support/Postgres/var-16/postgresql.conf"
Using postgresql.conf at this path:
/Users/gscar/Library/Application Support/Postgres/var-16/postgresql.conf

Writing backup to:
/var/folders/dy/9px5kt5d2xn8wpnx1lh9gfwc0000gn/T/timescaledb_tune.backup202401140926

success: shared_preload_libraries is set correctly

Recommendations based on 32.00 GB of available memory and 10 CPUs for PostgreSQL 16

Memory settings recommendations
success: memory settings are already tuned

Parallelism settings recommendations
success: parallelism settings are already tuned

WAL settings recommendations
success: WAL settings are already tuned

Background writer settings recommendations
success: background writer settings are already tuned

Miscellaneous settings recommendations
success: miscellaneous settings are already tuned
Saving changes to: /Users/gscar/Library/Application Support/Postgres/var-16/postgresql.conf

#### Put additions above ## ToDo
