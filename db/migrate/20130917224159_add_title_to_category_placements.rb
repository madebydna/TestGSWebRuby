class AddTitleToCategoryPlacements < ActiveRecord::Migration
  def change
    add_column :category_placements, :title, :string
  end
end
