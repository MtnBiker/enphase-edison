class Month< ApplicationRecord
  self.table_name = 'view_months' # Using a view in Rails. ChatGPT
  self.primary_key = "datetime"
  
  belongs_to :energy
  
  def readonly?
    true
  end
end
