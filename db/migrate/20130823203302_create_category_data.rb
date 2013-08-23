class CreateCategoryData < ActiveRecord::Migration
  def change
    create_table :category_data do |t|
      t.integer :category_id
      t.string :response_key
      t.string :response_label
      t.integer :collection_id

      t.timestamps
    end
  end
end
