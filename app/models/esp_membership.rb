class EspMembership < ActiveRecord::Base
  self.table_name = 'esp_membership'

  db_magic :connection => :gs_schooldb

  belongs_to :user, foreign_key: 'member_id'

  scope :active, -> { where(active: 1) }

  scope :for_school, ->(school) { where(school_id: school.id, state: school.state) }

  def approved?
    status == 'approved'
  end

  def provisional?
    status == 'provisional'
  end

end
