class AddJsonConfigToCategoryData < ActiveRecord::Migration
  def change
    add_column :category_data, :json_config, :string
  end
end
