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
➜ gem install timescaledb # this doesn't get in the app, mayb bundle install timescaledb would
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
