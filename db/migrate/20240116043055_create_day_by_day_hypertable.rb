class CreateEnergyHypertable < ActiveRecord::Migration[7.1]
  def change
    # execute "SELECT create_hypertable('energies', by_range('datetime'));"
  end
end
# https://docs.timescale.com/quick-start/latest/ruby/explore-aggregation-functions
# Had already done this so commented out
