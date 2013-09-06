class AddOrderToCategoryPlacements < ActiveRecord::Migration
  def change
    add_column :category_placements, :order, :integer
  end
end
