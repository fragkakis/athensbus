class AddDirectionToRoutes < ActiveRecord::Migration[8.0]
  def change
    add_column :routes, :direction, :string
  end
end
