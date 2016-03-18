class Products < ActiveRecord::Base
  self.table_name = 'products'
  has_many :user_product_grade_maps
  has_many :sms_users, through: :user_product_grade_maps
  has_many :grades, through: :user_product_grade_maps
  has_many :languages, through: :user_product_grade_maps

  db_magic :connection => :gs_schooldb
end