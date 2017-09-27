class EspMembership < ActiveRecord::Base
  include PhotoUploadConcerns

  self.table_name = 'esp_membership'

  db_magic :connection => :gs_schooldb

  belongs_to :user, foreign_key: 'member_id'
  has_many :osp_form_responses, :class_name => 'OspFormResponses'

  attr_accessible :member_id, :created, :updated, :state, :school_id, :status,:active,:job_title,:web_url,:note
  attr_accessor :school


  scope :active, -> { where(active: 1) }

  # 'status' is either 'approved', 'pre-approved', 'provisional', 'rejected', or 'disabled'
  scope :approved_or_provisional, -> { where(status: ['approved', 'provisional']) }

  scope :for_school, ->(school) { where(school_id: school.id, state: school.state) }

  def approved?
    status == 'approved' && active == true
  end

  def provisional?
    status == 'provisional'
  end

  def approve_provisional_osp_user_data
    osp_form_responses = OspFormResponse.where(esp_membership_id: id)
    osp_form_responses.each do |osp_form_response|
      create_update_queue_row!(osp_form_response.response)
    end
    approve_all_images_for_member(id)
    EspMembership.find_by(id: id, status: 'approved', active: true).tap do |em|
      SchoolUser.make_from_esp_membership(em) if em
    end
  end

  def create_update_queue_row!(response_blob)
    begin
      error = UpdateQueue.create(
        source: :osp_form,
        priority: 2,
        update_blob: response_blob
      ).errors.full_messages

      GSLogger.error(:osp, nil, vars: params, message: "Didnt save osp response to update_queue table #{[*error].first}") if error.present?
      error

    rescue => error
      GSLogger.error(:osp, error, vars: params, message: 'Didnt save osp response to update_queue table')
      error.presence || ["An error occured"]
    end
  end

end
