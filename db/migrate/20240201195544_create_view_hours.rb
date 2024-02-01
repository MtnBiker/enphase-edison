class CreateViewHours < ActiveRecord::Migration[7.1]
  def change
    create_view :view_hours
  end
end
