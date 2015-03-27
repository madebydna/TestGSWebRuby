class OspFormResponse < ActiveRecord::Base

  include JsonifiedAttributeConcerns

  db_magic :connection => :gs_schooldb
  self.table_name = 'osp_form_responses'

  attr_accessible :esp_membership_id, :osp_question_id, :response, :updated

  belongs_to :esp_membership, foreign_key: 'esp_membership_id'

  belongs_to :osp_question, :class_name => 'OspQuestion', foreign_key: 'osp_question_id'

  jsonified_attribute :responses, json_attribute: :responses, type: :string




  def  self.find_form_data_for_school_state(state,schoolId)
    OspFormResponse.joins(:esp_membership).where('esp_membership.state' => state ,'esp_membership.school_id'=> schoolId).order('osp_question_id').order('updated desc ')
  end

  def self.time_and_values_from_osp_form(key,osp_form_data)
    response_values = []
    osp_form_created_time = nil
    osp_form_data.each { |form_row |
      parsed_response = JSON.parse(form_row.response)
      key_name = parsed_response.keys.first
      if key_name == key
        values = parsed_response[key_name]
        response_values = []
        values.each { |value|
        response_values.push(value['value'])
        osp_form_created_time = Time.parse(value['created'])
        }
        # Get the key value with the latest timestamp and then break the loop
        break
      end
    }
    if osp_form_created_time && response_values
    return osp_form_created_time,response_values
    end
  end

  def self.values_for(key, osp_form_data, school_with_esp_data)
    school_cache_values = school_with_esp_data.values_for(key)
    osp_form_values = time_and_values_from_osp_form(key, osp_form_data)
    # By default school cache values are selected first
    values = school_cache_values
    if osp_form_values.present? && !school_cache_values.present?
        values = osp_form_values[1]
    elsif osp_form_values.present?  && school_cache_values.present?
          if  osp_form_values[0] > school_with_esp_data.created_time_for(key)
              values = osp_form_values[1]
          end
    end
    values
  end

end
