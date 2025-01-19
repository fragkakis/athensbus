class CreateArrivals < ActiveRecord::Migration[8.0]
  def change
    create_table :arrivals do |t|
      t.references :vehicle, null: false, foreign_key: true
      t.references :stop, null: false, foreign_key: true
      t.references :route, null: false, foreign_key: true
      t.timestamps
    end
  end
end
