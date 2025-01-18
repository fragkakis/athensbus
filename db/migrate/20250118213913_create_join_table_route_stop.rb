class CreateJoinTableRouteStop < ActiveRecord::Migration[8.0]
  def change
    create_join_table :routes, :stops do |t|
      t.integer :order

      t.index [:route_id, :stop_id]
      t.index [:stop_id, :route_id]
    end
  end
end
