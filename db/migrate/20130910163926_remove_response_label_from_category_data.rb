class RemoveResponseLabelFromCategoryData < ActiveRecord::Migration
  def up
    remove_column :category_data, :response_label
  end

  def down
    add_column :category_data, :response_label, :string
  end
end
