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
