class AddSortOrderToCategoryData < ActiveRecord::Migration
  def change
    add_column :category_data, :sort_order, :integer
  end
end
