class AddSizeToCategoryPlacement < ActiveRecord::Migration
  def change
    add_column :category_placements, :size, :integer
  end
end
