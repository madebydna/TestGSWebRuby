class AddLabelToCategoryData < ActiveRecord::Migration
  def change
    add_column :category_data, :label, :string
  end
end
