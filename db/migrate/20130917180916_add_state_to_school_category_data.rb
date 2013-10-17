class AddStateToSchoolCategoryData < ActiveRecord::Migration
  db_magic connections: States.abbreviations_as_symbols
  def change
    add_column :school_category_data, :state, :string
  end
end
