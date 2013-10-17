require 'states'
class CreateSchoolCategoryData < ActiveRecord::Migration
  db_magic connections: States.abbreviations_as_symbols

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
