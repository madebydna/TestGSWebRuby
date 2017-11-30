class OspQuestion < ActiveRecord::Base
  include JsonifiedAttributeConcerns

  db_magic :connection => :gs_schooldb
  self.table_name = 'osp_questions'

  attr_accessible :esp_response_key, :question_label, :question_type, :default_config, :school_type, :level_code, :active,  :updated
  has_many :osp_display_configs
  has_many :osp_form_responses
  scope :active, -> { where(active: true) }

  jsonified_attribute :answers, :options, :validations, :year_display, json_attribute: :default_config, type: :string

  def level_code
    super.split(',')
  end

  def self.question_key_label_level_code(*response_keys)
    self.select(:esp_response_key, :level_code).active.where(esp_response_key: response_keys).each_with_object({}) do |obj, accum|
      accum[obj.esp_response_key] = {
          level_code: obj.level_code
      }
    end
  end

end
