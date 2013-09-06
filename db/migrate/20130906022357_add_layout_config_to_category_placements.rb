class AddLayoutConfigToCategoryPlacements < ActiveRecord::Migration
  def change
    add_column :category_placements, :layout_config, :text
  end
end
