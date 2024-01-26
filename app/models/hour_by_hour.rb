class HourByHour< ApplicationRecord
  self.table_name = 'hour_by_hours' # Using a view in Rails. ChatGPT
  self.primary_key = "datetime"
  
  belongs_to :energy
  
  def readonly?
    true
  end
  
 def self.refresh
   Scenic.database.refresh_materialized_view(hour_by_hours, concurrently: false, cascade: false)
 end
end

# Following https://medium.com/@rebo_dood/the-benefits-of-materialized-views-and-how-to-use-them-in-your-ruby-on-rails-project-4ac1b5432881