class AddSourceToCategoryData < ActiveRecord::Migration
  def change
    add_column :category_data, :source, :string
  end
end
