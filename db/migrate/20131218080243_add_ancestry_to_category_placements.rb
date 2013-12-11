class AddAncestryToCategoryPlacements < ActiveRecord::Migration
  def change
    add_column :category_placements, :ancestry, :string
  end
end
