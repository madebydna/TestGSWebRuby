class RemoveCategoryFromSchoolCategoryData < ActiveRecord::Migration
  def up
    remove_column :school_category_data, :category_id
  end

  def down
    add_column :school_category_data, :category_id, :integer
  end
end
