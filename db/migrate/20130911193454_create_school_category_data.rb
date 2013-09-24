class CreateSchoolCategoryData < ActiveRecord::Migration
  using_group(:state_dbs)

  def self.up
    create_table :school_category_data do |t|
      t.string :key
      t.integer :school_id
      t.text :school_data

      t.timestamps
    end

    add_index :school_category_data, :school_id
  end
end
