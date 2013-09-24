class CreateResponseValues < ActiveRecord::Migration
  def change
    create_table :response_values do |t|
      t.string :response_value
      t.string :response_label
      t.integer :collection_id

      t.timestamps
    end

    add_index :response_values, :response_value
    add_index :response_values, :collection_id
  end
end
