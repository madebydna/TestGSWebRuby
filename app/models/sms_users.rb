class SmsUsers < ActiveRecord::Base
  self.table_name = 'sms_users'
  has_many :user_product_grade_maps
  has_many :products, through: :user_product_grade_maps, inverse_of: :sms_users
  has_many :grades, through: :user_product_grade_maps, inverse_of: :sms_users
  has_many :languages, through: :user_product_grade_maps, inverse_of: :sms_users

  db_magic :connection => :gs_schooldb
end