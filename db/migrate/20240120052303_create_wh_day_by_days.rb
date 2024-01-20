class CreateWhDayByDays < ActiveRecord::Migration[7.1]
  def change
    create_table :wh_day_by_days do |t|

      t.timestamps
    end
  end
end
