module SchoolProfiles
  class PrivateSchoolInfo

    attr_reader :school, :school_cache_data_reader

    OVERVIEW_CACHE_KEYS = %w(best_known_for anything_else start_time end_time schedule transportation dress_code boarding school_sub_type coed college_destination_1)
    ENROLLMENT_CACHE_KEYS = %w(admissions_url application_deadline_date application_requirements tuition_low tuition_high tuition_year financial_aid_type pk_financial_aid students_vouchers)
    CLASSES_CACHE_KEYS = %w(arts_media arts_music arts_performing_written arts_visual foreign_language ap_classes)
    SPORTS_CLUBS_CACHE_KEYS = %w(boys_sports girls_sports student_clubs)

    NO_DATA_TEXT = 'Data not provided by the school'

    def initialize(school, school_cache_data_reader)
      @school = school
      @school_cache_data_reader = school_cache_data_reader
    end

    def private_school_cache_data
      @school_cache_data_reader.esp_responses_data(*OVERVIEW_CACHE_KEYS,*ENROLLMENT_CACHE_KEYS,*CLASSES_CACHE_KEYS,*SPORTS_CLUBS_CACHE_KEYS)
    end

    def private_school_datas(*cache_keys)
      osp_keys = osp_question_metadata.slice(*cache_keys).keys
      used_keys = keys_with_data(*cache_keys)
      no_data_keys = (osp_keys - used_keys)
      foo = private_school_cache_data.slice(*cache_keys).each_with_object([]) do |(key, value), accum|
        responses = value.keys
        translated_responses = responses.map{|response| data_label(response)}
        accum << {
            response_key: data_label(key),
            response_value: translated_responses
        }
      end
      no_data_keys.each do |no_data_key|
        foo << {response_key: data_label(no_data_key), response_value: Array(NO_DATA_TEXT)}
      end
      foo
    end

    def keys_with_data(*cache_keys)
      private_school_cache_data.slice(*cache_keys).keys
    end

    def osp_question_metadata
      @_osp_question_metadata ||= OspQuestion.question_key_label_level_code(*OVERVIEW_CACHE_KEYS,*ENROLLMENT_CACHE_KEYS,*CLASSES_CACHE_KEYS,*SPORTS_CLUBS_CACHE_KEYS)
    end

    def old_data_for_view(*cache_keys)
      osp_question_metadata.select do |response_key,value|
        if private_school_datas(*cache_keys).keys.include?(response_key)
          value.merge!(private_school_datas(*cache_keys)[response_key])
        end
      end
    end

    def keys_to_hide_if_no_data
      %w(best_known_for anything_else)
    end

    def tab_config
      return nil if private_school_cache_data.blank?
      [
          {data_label(:overview) => private_school_datas(*OVERVIEW_CACHE_KEYS)},
          {data_label(:enrollment) => private_school_datas(*ENROLLMENT_CACHE_KEYS)},
          {data_label(:classes) => private_school_datas(*CLASSES_CACHE_KEYS)},
          {data_label(:sports_and_clubs) => private_school_datas(*SPORTS_CLUBS_CACHE_KEYS)}
      ]
    end

    def data_label(key)
      I18n.t(key.to_sym, scope: 'lib.private_school_info', default: I18n.db_t(key, default: key))
    end

  end
end

