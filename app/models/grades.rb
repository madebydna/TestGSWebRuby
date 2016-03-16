class Grades < ActiveRecord::Base
  self.table_name = 'grades'
  has_many :user_product_grade_maps
  has_many :sms_users, through: :user_product_grade_maps
  has_many :products, through: :user_product_grade_maps
  has_many :languages, through: :user_product_grade_maps

  db_magic :connection => :gs_schooldb
end