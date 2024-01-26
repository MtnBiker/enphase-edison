class CreateMonthScenics < ActiveRecord::Migration[7.1]
  def change
    create_view :month_scenics
  end
end
