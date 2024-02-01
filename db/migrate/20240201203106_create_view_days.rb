class CreateViewDays < ActiveRecord::Migration[7.1]
  def change
    create_view :view_days
  end
end
