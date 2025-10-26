class CreateDailyVehicleCounts < ActiveRecord::Migration[8.0]
  def change
    create_table :daily_vehicle_counts do |t|
      t.date :date, null: false
      t.integer :vehicle_count, null: false

      t.timestamps
    end

    add_index :daily_vehicle_counts, :date, unique: true
  end
end
