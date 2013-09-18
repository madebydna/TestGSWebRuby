class AddStateToSchoolCategoryData < ActiveRecord::Migration
  using(:state_dbs)
  def change
    add_column :school_category_data, :state, :string
  end
end
