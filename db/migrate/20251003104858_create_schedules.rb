class CreateSchedules < ActiveRecord::Migration[8.0]
  def change
    create_table :schedules do |t|
      t.references :route, null: false, foreign_key: true
      t.string :type, null: false
      t.date :date, null: false
      t.jsonb :departure_times, default: [], null: false
      t.timestamps
    end

    add_index :schedules, [:route_id, :type], unique: true
  end
end
