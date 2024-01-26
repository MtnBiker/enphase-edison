class CreateDayByDays < ActiveRecord::Migration[7.1]
  def change
    create_view :day_by_days, materialized: true
  end
end
