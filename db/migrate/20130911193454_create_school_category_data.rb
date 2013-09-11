class CreateSchoolCategoryData < ActiveRecord::Migration
  def change
    create_table :school_category_data do |t|
      t.string :key
      t.integer :school_id
      t.text :school_data

      t.timestamps
    end
  end
end
