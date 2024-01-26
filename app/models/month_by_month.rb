class MonthByMonth< ApplicationRecord
  self.table_name = 'month_by_month' # Using a view in Rails. ChatGPT
  self.primary_key = "datetime"
  
  belongs_to :energy
  
  def readonly?
    true
  end
  
 def self.refresh
   Scenic.database.refresh_materialized_view(month_by_month, concurrently: false, cascade: false)
 end
end

# Following https://medium.com/@rebo_dood/the-benefits-of-materialized-views-and-how-to-use-them-in-your-ruby-on-rails-project-4ac1b5432881