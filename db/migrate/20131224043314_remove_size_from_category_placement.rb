class RemoveSizeFromCategoryPlacement < ActiveRecord::Migration
  def up
    remove_column :category_placements, :size
  end

  def down
    add_column :category_placements, :size, :string
  end
end
