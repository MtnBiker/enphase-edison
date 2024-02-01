class CreateViewMonths < ActiveRecord::Migration[7.1]
  def change
    create_view :view_months
  end
end
