class CreateSchoolCategoryData < ActiveRecord::Migration
  def change
    create_table :school_category_data do |t|
      t.integer :school_id, :null => false
      t.integer :category_id
      t.string :key
      t.string :value
      t.string :value_type
      t.boolean :active

      t.timestamps
    end
  end
end
