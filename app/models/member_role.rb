class MemberRole < ActiveRecord::Base
  self.table_name = 'member_role'

  db_magic :connection => :gs_schooldb

  belongs_to :user, foreign_key: 'member_id'
  belongs_to :role, foreign_key: 'role_id'

end
