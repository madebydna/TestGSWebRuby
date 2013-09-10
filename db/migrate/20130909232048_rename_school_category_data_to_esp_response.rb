class RenameSchoolCategoryDataToEspResponse < ActiveRecord::Migration
  def change
    rename_table :school_category_datas, :esp_responses
  end
end
