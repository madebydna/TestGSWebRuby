class Osp::OspQuestion < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name = 'osp_questions'

  attr_accessible :esp_response_key, :question_label, :question_type, :default_config, :school_type, :level_code, :active,  :updated
  belongs_to :osp_display_config, :class_name => 'Osp::OspDisplayConfig'
  scope :active, -> { where(active: true) }

  def answers
      question_json_config[:answers]
  end

  def label
     self.question_label
  end


  def question_json_config
    json = read_attribute(:default_config)
    if json.present?
      begin results = JSON.parse(json,symbolize_names: true)
      rescue JSON::ParserError => e
        results = {}
        Rails.logger.debug "ERROR: parsing JSON Question Config for Question ID  #{self.id} \n" +
                               "Exception message: #{e.message}"
      end
      results
    else
      {}
    end
  end


end
