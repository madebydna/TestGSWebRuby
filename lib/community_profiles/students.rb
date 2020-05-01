module CommunityProfiles
  class Students

    OTHER_BREAKDOWN_KEYS = [
        'English learners',
        'Students participating in free or reduced-price lunch program',
    ].freeze

    GENDER_KEYS = %w(Male Female).freeze

    def initialize(cache_data_reader:)
      @cache_data_reader = cache_data_reader
    end

    def community_type
      @_community_type ||= begin
        if @cache_data_reader.is_a?(DistrictCacheDataReader)
          'district'
        elsif @cache_data_reader.is_a?(StateCacheDataReader)
          'state'
        else
          raise NotImplementedError.new("@cache_data_reader must be valid in #{self.class.name}#community_type")
        end
      end
    end

    def cache_ethnicity_data
      @_cache_ethnicity_data ||= @cache_data_reader.ethnicity_data.select(&with_valid_values)
    end

    def ethnicity_data
      @_ethnicity_data ||= (
        cache_ethnicity_data.map do |hash|
          {
              breakdown: ethnicity_label(hash['breakdown']),
              "#{community_type}_value".to_sym => hash["#{community_type}_value"]
          }.compact
        end
      )
    end

    def ethnicity_data_source
      cache_ethnicity_data.map {|hash| {source: hash['source'], year: hash['year']} }.uniq
    end

    def sources_text
      str = '<div class="sourcing">'
      str << '<h1>' + static_label('title') + '</h1>'
      if ethnicity_data_source.present?
        str << '<div>'
        str << '<h4>' + static_label('ethnicity') + '</h4>'
        str << '<p><span class="emphasis">' + static_label('source') + "</span>: #{ethnicity_data_source.map { |h| data_label(h[:source]) }.join(', ')}, "
        str << "#{ethnicity_data_source.map { |h| data_label(h[:year]) }.join(', ')}</p>"
        str << '</div>'
      end
      if gender_data_source.present?
        str << '<div>'
        str << '<h4>' + static_label('gender') + '</h4>'
        str << '<p><span class="emphasis">' + static_label('source') + "</span>: #{data_label(gender_data_source[:source])}, "
        str << "#{gender_data_source[:year]}</p>"
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

    def cache_gender_data
      @_cache_gender_data ||= @cache_data_reader.metrics_data(*GENDER_KEYS)
    end

    def gender_data
      @_gender_data ||=(
        cache_gender_data.select {|k,v| v.first["#{community_type}_value"] > 0}
      )
    end

    def gender_data_source
      @_gender_data_source ||= gender_data.values.flatten.map {|hash| {source: hash['source'], year: hash['year']} }.uniq.first
    end

    # Filtered data for the Student Demographics community module
    def ethnicity_student_demo_data
      ethnicity_data.select { |h| h["#{community_type}_value".to_sym] > 0 }
    end

    def subgroups_student_demo_data
      if subgroups_data.any? { |k, v| (v.length > 0) && (v[0]['breakdown'] === 'All students') && (v[0]["#{community_type}_value"] > 0) }
        return subgroups_data
      end
      {}
    end

    def gender_student_demo_data
      gender_data.reject { |k, v| v.empty? }
    end

    def students_demographics
      {}.tap do |h|
        h['ethnicityData'] = ethnicity_student_demo_data
        h['subgroupsData'] = subgroups_student_demo_data
        h['genderData'] = gender_student_demo_data
        h['translations'] = translations
        h['sources'] = sources_text
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
      @_subgroups_data ||= (
        @cache_data_reader.metrics_data(*OTHER_BREAKDOWN_KEYS).each_with_object({}) do |(key, value), hash|
          data_hash = value.first
          if data_hash["#{community_type}_value"] > 0
            hash[key] = [{}.tap do |h|
             h["breakdown"] =  data_hash['breakdown']
             h["#{community_type}_value"] =  data_hash["#{community_type}_value"]
             h["source"] =  data_hash['source']
             h["year"] =  data_hash['year']
             h["state_average"] =  data_hash['state_average'] if community_type != 'state'
            end]
          end
        end
      )
    end

    def subgroups_data_sources
      @_subgroups_data_sources ||= (
        subgroups_data.each_with_object({}) do |(data_type, array_of_one_hash), output|
          array_of_one_hash.each do |hash|
            output[data_type] = {
                source: hash['source'],
                year: hash['year']
            }
          end
        end
      )
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

    private

    def with_valid_values
      lambda {|e| e["#{community_type}_value"] > 0 }
    end

  end
end
