class RemoveValueTypeFromSchoolCategoryData < ActiveRecord::Migration
  def up
    remove_column :school_category_data, :value_type
  end

  def down
    add_column :school_category_data, :value_type, :string
  end
end
