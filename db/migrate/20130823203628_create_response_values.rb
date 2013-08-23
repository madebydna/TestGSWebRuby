class CreateResponseValues < ActiveRecord::Migration
  def change
    create_table :response_values do |t|
      t.string :response_value
      t.string :response_label
      t.integer :collection_id

      t.timestamps
    end
  end
end
