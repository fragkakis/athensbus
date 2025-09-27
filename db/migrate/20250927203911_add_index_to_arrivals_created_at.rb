class AddIndexToArrivalsCreatedAt < ActiveRecord::Migration[8.0]
  def change
    add_index :arrivals, :created_at
  end
end
