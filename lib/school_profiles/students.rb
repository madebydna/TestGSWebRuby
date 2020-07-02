module SchoolProfiles
  class Students
    include Qualaroo
    include SharingTooltipModal

    OTHER_BREAKDOWN_KEYS = [
        'English learners',
        'Students participating in free or reduced-price lunch program',
    ].freeze

    GENDER_KEYS = %w(Male Female).freeze

    def initialize(school_cache_data_reader:)
      @school_cache_data_reader = school_cache_data_reader
    end

    def share_content
      share_tooltip_modal('Students', @school_cache_data_reader.school)
    end

    def qualaroo_module_link
      qualaroo_iframe(:students, @school_cache_data_reader.school.state, @school_cache_data_reader.school.id.to_s)
    end

    def ethnicity_data
      @_ethnicity_data ||= (
        @school_cache_data_reader.ethnicity_data.select { |e| e.has_key?('school_value') }.map do |hash|
          {
              breakdown: ethnicity_label(hash['breakdown']),
              school_value: hash['school_value']
          }.compact
        end
      )
    end

    def ethnicity_data_source
      @_ethnicity_data_source ||= (
        # TODO: This iterates over each sub-hash, but overwrites the same key. Either just do it for the first one
        #       or collect them all (in case some are different), and handle it as an array below.
        @school_cache_data_reader.ethnicity_data.select { |e| e.has_key?('school_value') }.each_with_object({}) do |hash, output|
          output['ethnicity'] = {
              source: hash['source'],
              year: hash['year']
          }.compact
        end
      )
    end

    def sources_text
      str = '<div class="sourcing">'
      str << '<h1>' + static_label('title') + '</h1>'
      if ethnicity_data_source.present?
        str << '<div>'
        str << '<h4>' + static_label('ethnicity') + '</h4>'
        str << '<p><span class="emphasis">' + static_label('source') + "</span>: #{data_label(ethnicity_data_source['ethnicity'][:source])}, "
        str << "#{ethnicity_data_source['ethnicity'][:year]}</p>"
        str << '</div>'
      end
      if gender_data_source.present?
        str << '<div>'
        str << '<h4>' + static_label('gender') + '</h4>'
        str << '<p><span class="emphasis">' + static_label('source') + "</span>: #{data_label(gender_data_source['gender'][:source])}, "
        str << "#{gender_data_source['gender'][:year]}</p>"
        str << '</div>'
      end
      if subgroups_data_sources.present?
        subgroups_data_sources.each do |(data_type, source_hash)|
          str << '<div>'
          str << '<h4>' + data_label(data_type) + '</h4>'
          str << '<p><span class="emphasis">' + static_label('source') + "</span>: #{data_label(source_hash[:source])}, "
          str << "#{source_hash[:year]}</p>"
          str << '</div>'
        end
      end
      str << '</div>'
      str
    end

    def gender_data
      @school_cache_data_reader.decorated_metrics_datas(*GENDER_KEYS)
    end

    def gender_data_source
      gender_data.each_with_object({}) do |(_, array_of_one_hash), output|
        array_of_one_hash.each do |hash|
          output['gender'] = {
              source: hash['source'],
              year: hash['year']
          }
        end
      end
    end

    # TODO: ethnicity_data translates the keys, but this method does not. We should translate
    #       here so that we don't have to duplicate the translations in JavaScript
    def subgroups_data
      @school_cache_data_reader.decorated_metrics_datas(*OTHER_BREAKDOWN_KEYS)
    end

    def subgroups_data_sources
      subgroups_data.each_with_object({}) do |(data_type, array_of_one_hash), output|
        array_of_one_hash.each do |hash|
          output[data_type] = {
              source: hash['source'],
              year: hash['year']
          }
        end
      end
    end

    def static_label(key)
      I18n.t(key.to_sym, scope: 'lib.students', default: key)
    end

    # For ethnicity breakdowns we share translations with test scores for consistency
    def ethnicity_label(key)
      I18n.t(key, scope: 'lib.equity_test_scores', default: I18n.db_t(key, default: key))
    end

    # All other data labels should default to students and then db_t
    def data_label(key)
      I18n.t(key, scope: 'lib.students', default: I18n.db_t(key, default: key))
    end

    def visible?
      ethnicity_data.present? || gender_data.present? || subgroups_data.present?
    end
  end
end
