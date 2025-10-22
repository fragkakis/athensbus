class AddIndexOnDateCreatedAtToArrivals < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!
  
  def change
    add_index :arrivals,
              "date(created_at)",
              name: "index_arrivals_on_date_created_at",
              algorithm: :concurrently
  end
end
