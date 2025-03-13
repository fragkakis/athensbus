class CreateStops < ActiveRecord::Migration[8.0]
  def change
    create_table :stops do |t|
      t.string :code, index: { unique: true }
      t.string :stop_id
      t.string :description
      t.string :description_en
      t.string :street
      t.string :street_en
      t.string :heading
      t.string :lat
      t.string :lng
      t.string :stop_type
      t.boolean :amea
      t.jsonb :last_sync_pending_arrivals, default: {}
      t.timestamp :last_synced_at

      t.timestamps
    end
  end
end
