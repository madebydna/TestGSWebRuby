class Osp::OspQuestion < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name = 'osp_question'

  attr_accessible :esp_response_key, :question_label, :question_type, :default_config, :school_type, :level_code, :active,  :updated
  belongs_to :osp_display_config, :class_name => 'Osp::OspDisplayConfig'
  scope :active, -> { where(active: true) }



  def answer_set
    # use quality or p_overall(for prek) for star counts and overall
    # score.OM-209
    JSON.parse('[{"anserSet":[{"AV1":1},{"AV2":2}]},{"label":"oberride"}]')
  end

  def answers
    # binding.pry;
    result = {}
    self.question_json_config.each do |attribute|
      attribute.key("answerSet") == "answerSet"
      result = attribute
    end
    result
  end


  def question_json_config
    json = read_attribute(:default_config)
    if json.present?
      begin results = JSON.parse(json,symbolize_names: true)
      rescue JSON::ParserError => e
        results = {}
        Rails.logger.debug "ERROR: parsing JSON Question Config" +
                               "Exception message: #{e.message}"
      end

      results
    else
      {}
    end
  end


end
