module SchoolProfiles
  class Students
    include Qualaroo

    OTHER_BREAKDOWN_KEYS = [
        'English learners',
        'Students participating in free or reduced-price lunch program',
    ].freeze

    GENDER_KEYS = %w(Male Female).freeze

    def initialize(school_cache_data_reader:)
      @school_cache_data_reader = school_cache_data_reader
    end

    def qualaroo_module_link
      qualaroo_iframe(:students, @school_cache_data_reader.school.state, @school_cache_data_reader.school.id.to_s)
    end

    def ethnicity_data
      @_ethnicity_data ||= (
        @school_cache_data_reader.ethnicity_data.select { |e| e.has_key?('school_value') }.map do |hash|
          {
              breakdown: data_label(hash['breakdown']),
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

    def sources_for_view
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
      if subgroups_data_source.present?
        str << '<div>'
        str << '<h4>' + static_label('subgroups') + '</h4>'
        str << '<p><span class="emphasis">' + static_label('source') + "</span>: #{data_label(subgroups_data_source['subgroups'][:source])}, "
        str << "#{subgroups_data_source['subgroups'][:year]}</p>"
        str << '</div>'
      end
      str << '</div>'
      str
    end

    def gender_data
      @school_cache_data_reader.characteristics_data(*GENDER_KEYS)
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

    def subgroups_data
      @school_cache_data_reader.characteristics_data(*OTHER_BREAKDOWN_KEYS)
    end

    def subgroups_data_source
      subgroups_data.each_with_object({}) do |(_, array_of_one_hash), output|
        array_of_one_hash.each do |hash|
          output['subgroups'] = {
              source: hash['source'],
              year: hash['year']
          }
        end
      end
    end

    def static_label(key)
      I18n.t(key.to_sym, scope: 'lib.students', default: key)
    end

    def data_label(key)
      I18n.t(key, scope: 'lib.equity_test_scores', default: I18n.db_t(key, default: key))
    end

    def visible?
      ethnicity_data.present? || gender_data.present? || subgroups_data.present?
    end
  end
end
