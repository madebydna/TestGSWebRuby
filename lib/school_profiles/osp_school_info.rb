module SchoolProfiles
  class OspSchoolInfo
    include Qualaroo
    attr_reader :school, :school_cache_data_reader

    OVERVIEW_CACHE_KEYS = %w(best_known_for anything_else start_time end_time schedule transportation dress_code boarding school_sub_type coed college_destination_1)
    ENROLLMENT_CACHE_KEYS = %w(admissions_url application_deadline_date application_requirements tuition_low tuition_high tuition_year financial_aid_type pk_financial_aid students_vouchers)
    CLASSES_CACHE_KEYS = %w(arts_media arts_music arts_performing_written arts_visual foreign_language ap_classes)
    SPORTS_CLUBS_CACHE_KEYS = %w(boys_sports girls_sports student_clubs)

    OSP_CACHE_KEYS = {
        Overview: [
            {key: 'best_known_for', level_code: 'p,e,m,h', type: 'private,charter,public', no_data: false},
            {key: 'anything_else', level_code: 'p,e,m,h', type: 'private,charter,public', no_data: false},
            {key: 'start_time', level_code: 'p,e,m,h', type: 'private,charter,public'},
            {key: 'end_time', level_code: 'p,e,m,h', type: 'private,charter,public'},
            {key: 'schedule', level_code: 'p,e,m,h', type: 'private,charter,public'},
            {key: 'transportation', level_code: 'p,e,m,h', type: 'private,charter,public', layout: 'list'},
            {key: 'dress_code', level_code: 'p,e,m,h', type: 'private,charter,public'},
            {key: 'boarding', level_code: 'e,m,h', type: 'private,charter,public'},
            {key: 'school_sub_type', level_code: 'p,e,m,h', type: 'private,charter,public', layout: 'list'},
            {key: 'coed', level_code: 'p,e,m,h', type: 'private,charter,public'},
            {key: 'college_destination_1', level_code: 'h', type: 'private,charter,public', layout: 'list'}
        ],
        Enrollment: [
            {key: 'admissions_url', level_code: 'p,e,m,h', type: 'private,charter,public'},
            {key: 'application_deadline_date', level_code: 'e,m,h', type: 'private,charter,public'},
            {key: 'application_requirements', level_code: 'e,m,h', type: 'private,charter,public', layout: 'list'},
            {key: 'tuition_low', level_code: 'e,m,h', type: 'private'},
            {key: 'tuition_high', level_code: 'e,m,h', type: 'private'},
            {key: 'tuition_year', level_code: 'e,m,h', type: 'private'},
            {key: 'financial_aid_type', level_code: 'e,m,h', type: 'private', layout: 'list'},
            {key: 'pk_financial_aid', level_code: 'p', type: 'private,charter,public', layout: 'list'},
            {key: 'students_vouchers', level_code: 'e,m,h', type: 'private'}
        ],
        Classes: [
            {key: 'arts_media', level_code: 'e,m,h', type: 'private,charter,public', layout: 'list'},
            {key: 'arts_music', level_code: 'e,m,h', type: 'private,charter,public', layout: 'list'},
            {key: 'arts_performing_written', level_code: 'e,m,h', type: 'private,charter,public', layout: 'list'},
            {key: 'arts_visual', level_code: 'e,m,h', type: 'private,charter,public', layout: 'list'},
            {key: 'foreign_language', level_code: 'e,m,h', type: 'private,charter,public', layout: 'list'},
            {key: 'ap_classes', level_code: 'h', type: 'private,charter,public', layout: 'list'}
        ],
        Sports_and_clubs: [
            {key: 'boys_sports', level_code: 'e,m,h', type: 'private,charter,public', layout: 'list'},
            {key: 'girls_sports', level_code: 'e,m,h', type: 'private,charter,public', layout: 'list'},
            {key: 'student_clubs', level_code: 'e,m,h', type: 'private,charter,public', layout: 'list'}
        ]
    }

    NO_DATA_TEXT = 'no_data_text'
    SCHOOL_ADMIN = 'School administration'

    def grab_all_keys
      @_grab_all_keys ||= (
        keys = []
        OSP_CACHE_KEYS.each {|tab, content| content.each {|c| keys.push( c[:key] ) if level_code_matches?(c[:level_code]) && school_type_matches?(c[:type]) }}
        keys
      )
    end

    def qualaroo_module_link
      if @school.private_school?
        qualaroo_iframe(:general_information_private, @school_cache_data_reader.school.state, @school_cache_data_reader.school.id.to_s)
      else
        qualaroo_iframe(:general_information_public, @school_cache_data_reader.school.state, @school_cache_data_reader.school.id.to_s)
      end
    end

    def level_code_matches?(level_code)
      @school.includes_level_code? level_code.split(',')
    end

    def school_type_matches?(type)
      @school.includes_type? type.split(',')
    end

    def initialize(school, school_cache_data_reader)
      @school = school
      @school_cache_data_reader = school_cache_data_reader
    end

    def osp_school_cache_data
      @_osp_school_cache_data ||= @school_cache_data_reader.esp_responses_data(*grab_all_keys)
    end

    def osp_school_datas(*cache_keys)
      osp_question_metadata.slice(*cache_keys).each_with_object([]) do |(response_key, response_value), accum|
        next if (response_value[:level_code] & school_level_code).empty?
        data = osp_school_cache_data.slice(*cache_keys)
        next if (
        keys_to_hide_if_no_data.include?(response_key) &&
            (data[response_key].nil? || !data[response_key].keys.first.to_s.match(/\w+/))
        ) ## We dont't want to give no_data_text to a data-less key in keys_to_hide_if_no_data
        responses = data[response_key].present? ? data[response_key].keys : Array(NO_DATA_TEXT)
        if %w(best_known_for anything_else).include?(response_key)
          # causes these two data points to span two table columns
          translated_response_key = ['']
        else
          translated_response_key = data_label(response_key)
        end
        translated_responses = responses.map do |response|
          response_label(response_key, response)
        end
        accum << {
            response_key: translated_response_key,
            response_value: translated_responses
        }
      end
    end

    def school_level_code
      @_school_level_code ||= @school.level_code.split(',')
    end

    def osp_question_metadata
      @_osp_question_metadata ||= OspQuestion.question_key_label_level_code(*grab_all_keys)
    end

    def keys_to_hide_if_no_data
      %w(best_known_for anything_else '.')
    end

    def tab_config
      @_tab_config ||= (
        tab_config = []
        tab_config += [
          {
            key: :overview,
            title: data_label(:overview),
            data: osp_school_datas(*OVERVIEW_CACHE_KEYS),
            source: data_label(SCHOOL_ADMIN)
          },
          {
            key: :calendar,
            title: data_label(:calendar),
            data: true,
            source: 'Tandem'
          }
        ]
        if claimed?
          tab_config += [
            {
              key: :enrollment,
              title: data_label(:Enrollment),
              data: osp_school_datas(*ENROLLMENT_CACHE_KEYS),
              source: data_label(SCHOOL_ADMIN)
            }
          ]
        end
        unless @school.preschool?
          if claimed?
            tab_config << {
                key: :classes,
                title: data_label(:classes),
                data: osp_school_datas(*CLASSES_CACHE_KEYS),
                source: data_label(SCHOOL_ADMIN)
            }
            tab_config << {
                key: :sports_and_clubs,
                title: data_label(:sports_and_clubs),
                data: osp_school_datas(*SPORTS_CLUBS_CACHE_KEYS),
                source: data_label(SCHOOL_ADMIN)
            }
          end
        end
        tab_config
      )
    end

    def has_osp_classes?
      osp_school_datas(*CLASSES_CACHE_KEYS).reject { |h| h[:response_value].include?('Data not provided by the school') }.present?
    end

    def response_label(response_key, response_value)
      str = response_value
      response_value_look_up = response_value_label_lookup_table[[response_key, str]]
      translation = data_label(response_value_look_up)
      if translation.blank?
        translation = data_label(str)
      end
      translation
    end

    def response_value_label_lookup_table
      @_response_value_label_lookup_table ||= ResponseValue.lookup_table
    end

    def locality
      {}.tap do |hash|
        hash[:calendarURL] = ENV_GLOBAL['calendar_service_url']
        hash[:stateShort] =  school.state.upcase
        hash[:nces_code] = school.nces_code
      end
    end

    def data_label(str)
      if str.present?
        begin
          return str if str.to_s.gsub('.', '').blank?
          I18n.db_t(str.to_s, default:
              I18n.db_t(str.to_s.gsub('_', ' ').gs_capitalize_first, default:
                  I18n.db_t(str.to_s.gsub('_', ' ').gs_capitalize_words, default:
                      I18n.t(str.to_s.gsub('.', '').to_sym, scope: 'lib.osp_school_info', default: str)
                  )
              )
          )
        rescue StandardError => e
          GSLogger.error(:misc, e, message: 'Key is not found for translation - osp school info', vars: {key: str})
          I18n.t(NO_DATA_TEXT, scope: 'lib.osp_school_info')
        end
      end
    end

    def administrators_email_and_name
      data = @school_cache_data_reader.
          esp_responses_data('administrator_name','administrator_email')
      recipient_email = data.fetch('administrator_email', {}).keys.first
      recipient_name = data.fetch('administrator_name', {}).keys.first
      # Check characteristics data if esp fails
      if recipient_email.blank? && recipient_name.blank?
        data = @school_cache_data_reader.metrics_data('Head official name','Head official email address')
        recipient_email = data.fetch('Head official email address', [{}]).first['school_value']
        recipient_name = data.fetch('Head official name', [{}]).first['school_value']
      end
      return recipient_email, recipient_name
    end

    def mailto
      recipient_email, recipient_name = administrators_email_and_name

      return nil unless recipient_email && recipient_name
      osp_url = Rails.application.routes.url_helpers.osp_register_url(
          city: school.city,
          school_id: school.id.to_s,
          state: school.state,
          trailing_slash: false
      )
      crlf = '%0D%0A'

      if school.claimed?
        subject = 'Update your school’s GreatSchools profile page!'
        body = %(
            Dear #{recipient_name},#{crlf}
        #{crlf}
            You have “claimed” your school’s GreatSchools.org profile page, which means you can add and edit information at any time. This is a powerful way to ensure parents see up-to-date information about your school and what makes it special.#{crlf}
        #{crlf}
            It’s been awhile since you’ve made updates to your school’s page; log in at #{ERB::Util.url_encode(osp_url)} to share what’s new.#{crlf}
        #{crlf}
            Thank you,#{crlf}
            (your name)
          ).gsub(/^\s+/, '')
      else
        subject = 'Claim your school’s profile on GreatSchools.org!'
        body = %(
            Dear #{recipient_name},#{crlf}
        #{crlf}
            GreatSchools.org offers school administrators like you the ability to “claim” your school’s GreatSchools profile page so you can add and edit information. It’s a great way to help tell your school’s story and ensure parents see robust and accurate information.#{crlf}
        #{crlf}
            Get started by claiming your school’s profile page here: #{ERB::Util.url_encode(osp_url)}#{crlf}
        #{crlf}
            Thank you,#{crlf}
            (your name)
          ).gsub(/^\s+/, '')
      end

      "mailto:#{recipient_email}?subject=#{subject}&body=#{body}"
    end

    def claimed?
      school.claimed?
    end

    def sources
      tab_config.map do |h|
        source = {
            heading: h[:title]
        }
        source[:names] = [h[:source]]
        source[:years] = [nil]
        source
      end
    end
  end
end


