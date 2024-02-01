class Day < ApplicationRecord
  self.table_name = 'view_days' # Using a view in Rails. ChatGPT
  self.primary_key = "datetime"
  
  belongs_to :energy
  
  def readonly?
    true
  end
end
