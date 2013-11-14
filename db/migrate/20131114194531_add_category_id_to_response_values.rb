class AddCategoryIdToResponseValues < ActiveRecord::Migration
  def change
    add_column :response_values, :category_id, :integer
  end
end
