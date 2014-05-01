class AddKeyTypeToCategoryData < ActiveRecord::Migration
  def change
    add_column :category_data, :key_type, :string
  end
end
