class AddStateToSchoolCategoryData < ActiveRecord::Migration
  db_magic connections: States.abbreviations_as_symbols
  def change
    unless self.table_exists? :school_category_data
      add_column :school_category_data, :state, :string
    end
  end
end
