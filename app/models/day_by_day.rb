class DayByDay < ApplicationRecord
  self.table_name = 'day_by_day' # Using a view in Rails. ChatGPT
  self.primary_key = "datetime"
  
  def readonly?
    true
  end
  
  def self.refresh
    connection.execute('REFRESH MATERIALIZED VIEW day_by_day')
  end
end

# Following https://medium.com/@rebo_dood/the-benefits-of-materialized-views-and-how-to-use-them-in-your-ruby-on-rails-project-4ac1b5432881