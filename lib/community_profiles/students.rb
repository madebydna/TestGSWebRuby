module CommunityProfiles
  class Students
    # include Qualaroo
    # include SharingTooltipModal

    OTHER_BREAKDOWN_KEYS = [
        'English learners',
        'Students participating in free or reduced-price lunch program',
    ].freeze

    GENDER_KEYS = %w(Male Female).freeze

    def initialize(cache_data_reader:)
      @cache_data_reader = cache_data_reader
    end

    def share_content
      share_tooltip_modal('Students', @cache_data_reader.school)
    end

    def qualaroo_module_link
      qualaroo_iframe(:students, @cache_data_reader.school.state, @cache_data_reader.school.id.to_s)
    end

    def ethnicity_data
      @_ethnicity_data ||= (
        @cache_data_reader.ethnicity_data.select { |e| e.has_key?('district_value') }.map do |hash|
          {
              breakdown: ethnicity_label(hash['breakdown']),
              district_value: hash['district_value']
          }.compact
        end
      )
    end

    def ethnicity_data_source
      @_ethnicity_data_source ||= (
        # TODO: This iterates over each sub-hash, but overwrites the same key. Either just do it for the first one
        #       or collect them all (in case some are different), and handle it as an array below.
        @cache_data_reader.ethnicity_data.select { |e| e.has_key?('district_value') }.each_with_object({}) do |hash, output|
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
      @cache_data_reader.characteristics_data(*GENDER_KEYS)
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

    def students_demographics
      {}.tap do |h|
        h["ethnicityData"] = ethnicity_data
        h["subgroupsData"] = subgroups_data
        h["genderData"] = gender_data
        h['translations'] = translations
      end
    end

    def translations
      @_translations ||= {}.tap do |h|
        h['title'] = I18n.t('title', scope: 'school_profiles.students')
        h['subtitle'] = I18n.t('subtitle_html', scope: 'school_profiles.students')
      end
    end

    # TODO: ethnicity_data translates the keys, but this method does not. We should translate
    #       here so that we don't have to duplicate the translations in JavaScript
    def subgroups_data
      @_ethnicity_data_source ||= (
        # TODO: This iterates over each sub-hash, but overwrites the same key. Either just do it for the first one
        #       or collect them all (in case some are different), and handle it as an array below.
        @cache_data_reader.ethnicity_data.select { |e| e.has_key?('district_value') }.each_with_object({}) do |hash, output|
          output['ethnicity'] = {
              source: hash['source'],
              year: hash['year']
          }.compact
        end
      )
      @cache_data_reader.characteristics_data(*OTHER_BREAKDOWN_KEYS)
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
