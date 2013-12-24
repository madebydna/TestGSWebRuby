class AddIndexToCategoryData < ActiveRecord::Migration
  def change
    add_index :category_data, :source
  end
end
