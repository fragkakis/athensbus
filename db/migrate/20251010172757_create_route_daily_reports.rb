class CreateRouteDailyReports < ActiveRecord::Migration[8.0]
  def change
    create_table :route_daily_reports do |t|
      t.references :route, null: false, foreign_key: true
      t.date :date, null: false
      t.integer :executed_trips
      t.timestamps
    end

    add_index :route_daily_reports, [:route_id, :date], unique: true
    add_index :route_daily_reports, :date
  end
end
