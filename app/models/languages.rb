class Languages < ActiveRecord::Base
  self.table_name = 'language'
  has_many :user_product_grade_maps
  has_many :sms_users, through: :user_product_grade_maps
  has_many :products, through: :user_product_grade_maps
  has_many :grades, through: :user_product_grade_maps

  db_magic :connection => :gs_schooldb
end