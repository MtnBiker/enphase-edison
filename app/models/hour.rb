class Hour< ApplicationRecord
  self.table_name = 'view_hours' # Using a view in Rails. ChatGPT
  self.primary_key = "datetime"
  
  belongs_to :energy
  
  def readonly?
    true
  end
end
# Copied to some extend from HourByHour which was for a materialized view