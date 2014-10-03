class Role < ActiveRecord::Base
  self.table_name = 'role'

  db_magic :connection => :gs_schooldb

  has_many :member_roles, foreign_key: 'role_id'
  has_many :users, through: :member_roles #Need to use :through in order to use MemberRole model, to specify gs_schooldb

  def self.esp_superuser
    where(quay: 'ESP_SUPERUSER').first
  end

end
