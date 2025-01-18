class CreateRoutes < ActiveRecord::Migration[8.0]
  def change
    create_table :routes do |t|
      t.string :code, index: {unique: true}
      t.string :route_id
      t.string :description
      t.boolean :active, default: true
      t.string :description_en
      t.references :line, null: false, foreign_key: true

      t.timestamps
    end
  end
end
