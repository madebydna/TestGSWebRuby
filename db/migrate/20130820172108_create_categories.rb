class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.integer :parent_id
      t.string :name
      t.string :description

      t.timestamps
    end

    add_index :categories, :parent_id
  end
end
