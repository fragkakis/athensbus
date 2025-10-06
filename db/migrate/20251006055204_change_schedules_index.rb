class ChangeSchedulesIndex < ActiveRecord::Migration[8.0]
  def change
    remove_index :schedules, ["route_id", "type"]
    add_index :schedules, [:route_id, :type, :date], unique: true
  end
end
