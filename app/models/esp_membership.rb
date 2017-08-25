class EspMembership < ActiveRecord::Base

  self.table_name = 'esp_membership'

  db_magic :connection => :gs_schooldb

  belongs_to :user, foreign_key: 'member_id'
  has_many :osp_form_responses, :class_name => 'OspFormResponses'

  attr_accessible :member_id, :created, :updated, :state, :school_id, :status,:active,:job_title,:web_url,:note
  attr_accessor :school, :matched_contact, :has_active_memberships

  # Notes re: attributes:
  # 'active' is either 0 or 1
  # 'status' is either 'approved', 'pre-approved', 'provisional', 'rejected', or 'disabled'
  scope :active, -> { where(active: 1) }

  scope :approved_or_provisional, -> { where(status: ['approved', 'provisional']) }

  scope :for_school, ->(school) { where(school_id: school.id, state: school.state) }

  def approved?
    status == 'approved' && active == true
  end

  def provisional?
    status == 'provisional'
  end

  def set_highlight_color
    if @matched_contact
      return '#D1EFFA'
    elsif @has_active_memberships
      return '#ABF293'
    end
  end

end
