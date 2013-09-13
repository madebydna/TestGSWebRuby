class RenameSchoolCategoryDataToEspResponse < ActiveRecord::Migration
  def change
    rename_table :school_category_data, :esp_responses
  end
end
