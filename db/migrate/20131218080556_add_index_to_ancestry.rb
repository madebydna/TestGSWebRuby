class AddIndexToAncestry < ActiveRecord::Migration
  def up
    add_index :category_placements, :ancestry
  end

  def down
    remove_index :category_placements, :ancestry
  end
end
