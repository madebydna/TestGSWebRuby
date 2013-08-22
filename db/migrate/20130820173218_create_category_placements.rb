class CreateCategoryPlacements < ActiveRecord::Migration
  def change
    create_table :category_placements do |t|
      t.integer :category_id
      t.integer :collection_id
      t.integer :page_id
      t.integer :position

      t.timestamps
    end
  end
end
