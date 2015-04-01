class OspQuestion < ActiveRecord::Base
  include JsonifiedAttributeConcerns

  db_magic :connection => :gs_schooldb
  self.table_name = 'osp_questions'

  attr_accessible :esp_response_key, :question_label, :question_type, :default_config, :school_type, :level_code, :active,  :updated
  has_many :osp_display_configs, :class_name => 'OspDisplayConfig'
  has_many :osp_form_responses, :class_name => 'OspFormResponse'
  scope :active, -> { where(active: true) }

  jsonified_attribute :answers, :options, json_attribute: :default_config, type: :string

  def level_code
    super.split(',')
  end

  def self.find_by_question_key( key)
    self.active.where(esp_response_key: key).first
  end


end
