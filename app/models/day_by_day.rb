class DayByDay < ApplicationRecord
  self.table_name = 'day_by_days' # Using a view in Rails. ChatGPT
  self.primary_key = "datetime"
  
  belongs_to :energy
  
  def readonly?
    true
  end
  
  # Without Scenic
  # def self.refresh
  #   connection.execute('REFRESH MATERIALIZED VIEW day_by_day')
  # end
  
  def self.refresh
    Scenic.database.refresh_materialized_view(day_by_day, concurrently: false, cascade: false)
  end
end

# Following https://medium.com/@rebo_dood/the-benefits-of-materialized-views-and-how-to-use-them-in-your-ruby-on-rails-project-4ac1b5432881