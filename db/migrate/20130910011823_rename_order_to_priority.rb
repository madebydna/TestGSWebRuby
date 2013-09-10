class RenameOrderToPriority < ActiveRecord::Migration
  def change
    rename_column :category_placements, :order, :priority
  end
end
