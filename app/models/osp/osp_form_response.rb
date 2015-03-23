class OspFormResponse < ActiveRecord::Base

  include JsonifiedAttributeConcerns

  db_magic :connection => :gs_schooldb
  self.table_name = 'osp_form_responses'

  attr_accessible :esp_membership_id, :osp_question_id,:responses, :updated

  belongs_to :esp_membership, foreign_key: 'esp_membership_id'

  belongs_to :osp_question, :class_name => 'OspQuestion', foreign_key: 'osp_question_id'

  jsonified_attribute :responses, json_attribute: :responses, type: :string




  def  self.find_form_data_for_school_state(state,schoolId)
    OspFormResponse.joins(:esp_membership).where('esp_membership.state' => state ,'esp_membership.school_id'=> schoolId)
  end

  def self.created_time_from_osp_form(key,osp_form_data)
    osp_form_created_time = nil
    osp_form_data.each { |form_row |
      parsed_response = JSON.parse(form_row.response)
      key_name = parsed_response.keys.first
      if key_name == key
        values = parsed_response[key_name]
        value =values[0]
        if value.present?
          osp_form_created_time = Time.parse(value['created'])
        end
      end
    }
    osp_form_created_time
  end

  def self.values_from_osp_form(key,osp_form_data)
    response_values = []
    osp_form_data.each { |form_row |
      parsed_response = JSON.parse(form_row.response)
      key_name = parsed_response.keys.first
      if key_name == key
        values = parsed_response[key_name]
        response_values = []
        values.each { |value|
        response_values.push(value)
        }
      end
    }
    response_values
    # binding.pry
  end

  def self.values_for(key, osp_form_data, school_with_esp_data)
    school_cache_values = school_with_esp_data.values_for(key)
    osp_form_values = values_from_osp_form(key, osp_form_data)
    values = school_cache_values
    osp_from_data_for_key_time = created_time_from_osp_form(key, osp_form_data)
    if osp_form_values.present? && !school_cache_values.present?
        values = osp_form_values

    elsif !osp_form_values.present? && school_cache_values.present?
      values = school_cache_values

    end

    # binding.pry
    values
  end

end
