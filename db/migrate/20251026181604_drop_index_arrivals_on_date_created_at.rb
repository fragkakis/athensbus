class DropIndexArrivalsOnDateCreatedAt < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    remove_index :arrivals, name: "index_arrivals_on_date_created_at", algorithm: :concurrently
  end

  def down
    add_index :arrivals, "date(created_at)", name: "index_arrivals_on_date_created_at", algorithm: :concurrently
  end
end
