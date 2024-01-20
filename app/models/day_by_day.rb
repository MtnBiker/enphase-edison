class DayByDay < ApplicationRecord
  self.table_name = 'day_by_day' # Using a view in Rails. ChatGPT
  self.primary_key = "datetime"
end
