class CreateEnergyHypertable < ActiveRecord::Migration[7.1]
  def change
    # Not sure which is correct
    # execute "SELECT create_hypertable('energies', by_range('datetime'));"
    # execute "SELECT create_hypertable('energies', 'datetime');" # ChatGPT
  end
end
# https://docs.timescale.com/quick-start/latest/ruby/explore-aggregation-functions
# Had already done this so commented out
# PG::ServerError: ERROR:  table "energies" is already a hypertable
