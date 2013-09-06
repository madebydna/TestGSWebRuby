class AddLayoutToCategoryPlacements < ActiveRecord::Migration
  def change
    add_column :category_placements, :layout, :string
  end
end
