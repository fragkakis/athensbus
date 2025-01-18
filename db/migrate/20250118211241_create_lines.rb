class CreateLines < ActiveRecord::Migration[8.0]
  def change
    create_table :lines do |t|
      t.string :code, index: {unique: true}
      t.string :line_id
      t.string :description
      t.string :description_en

      t.timestamps
    end
  end
end
