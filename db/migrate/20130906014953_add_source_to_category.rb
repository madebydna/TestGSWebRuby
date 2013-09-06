class AddSourceToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :source, :string
  end
end
