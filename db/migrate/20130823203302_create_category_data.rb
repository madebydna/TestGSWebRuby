class CreateCategoryData < ActiveRecord::Migration
  def change
    create_table :category_data do |t|
      t.integer :category_id
      t.string :response_key
      t.string :response_label
      t.integer :collection_id

      t.timestamps
    end

    add_index :category_data, :category_id
    add_index :category_data, :response_key
  end
end
