class UserProductGradeLanguageMaps < ActiveRecord::Base
  self.table_name = 'user_product_grade_language_maps'
  belongs_to :sms_users
  belongs_to :products
  belongs_to :grades
  belongs_to :languages
end