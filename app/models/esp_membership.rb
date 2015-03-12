class EspMembership < ActiveRecord::Base
  self.table_name = 'esp_membership'

  db_magic :connection => :gs_schooldb

  belongs_to :user, foreign_key: 'member_id'
  has_many :osp_form_responses, :class_name => 'Osp::OspFormResponses'


  scope :active, -> { where(active: 1) }

  scope :for_school, ->(school) { where(school_id: school.id, state: school.state) }

  def approved?
    status == 'approved' && :active
  end

  def provisional?
    status == 'provisional'
  end

end
