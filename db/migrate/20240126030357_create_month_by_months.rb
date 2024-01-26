class CreateMonthByMonths < ActiveRecord::Migration[7.1]
  def change
    create_view :month_by_months, materialized: true
  end
end
 # materialized: true https://raghu-bhupatiraju.dev/implementing-materialized-views-in-rails-ffea22bd5d9cra