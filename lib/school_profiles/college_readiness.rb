module SchoolProfiles
  class CollegeReadiness
    attr_reader :school_cache_data_reader

    # Order matters - items display in configured order
    CHAR_CACHE_ACCESSORS = [
      {
        :cache => :characteristics,
        :data_key => '4-year high school graduation rate',
        :visualization => :person_bar_viz,
        :formatting => [:round_unless_less_than_1, :percent]
      },
      {
        :cache => :characteristics,
        :data_key => 'Percent of students who meet UC/CSU entrance requirements',
        :visualization => :single_bar_viz,
        :formatting => [:round_unless_less_than_1, :percent]
      },
      {
        :cache => :characteristics,
        :data_key => 'Average SAT score',
        :visualization => :single_bar_viz,
        :formatting => [:round],
        :range => (600..2400)
      },
      {
        :cache => :characteristics,
        :data_key => 'SAT percent participation',
        :visualization => :person_bar_viz,
        :formatting => [:round_unless_less_than_1, :percent]
      },
      {
        :cache => :characteristics,
        :data_key => 'Average ACT score',
        :visualization => :single_bar_viz,
        :formatting => [:round],
        :range => (1..36)
      },
      {
        :cache => :characteristics,
        :data_key => 'ACT participation',
        :visualization => :person_bar_viz,
        :formatting => [:round_unless_less_than_1, :percent]
      },
      {
        :cache => :gsdata,
        :data_key => 'Percentage AP enrolled grades 9-12',
        :visualization => :person_bar_viz,
        :formatting => [:to_f, :round_unless_less_than_1, :percent]
      },
      {
        :cache => :gsdata,
        :data_key => 'Percentage of students passing 1 or more AP exams grades 9-12',
        :visualization => :single_bar_viz,
        :formatting => [:to_f, :round_unless_less_than_1, :percent]
      }
    ].freeze

    def initialize(school_cache_data_reader:)
      @school_cache_data_reader = school_cache_data_reader
    end

    def faq
      @_faq ||= Faq.new(cta: I18n.t(:cta, scope: 'lib.college_readiness.faq'),
                        content: I18n.t(:content_html, scope: 'lib.college_readiness.faq'))
    end

    def rating
      ((1..10).to_a & [@school_cache_data_reader.college_readiness_rating]).first
    end

    def narration
      return nil unless rating.present? && (1..10).cover?(rating.to_i)
      key = '_' + ((rating / 2) + (rating % 2)).to_s + '_html'
      I18n.t(key, scope: 'lib.college_readiness.narration', default: I18n.db_t(key, default: key)).html_safe
    end

    def info_text
      I18n.t('lib.college_readiness.info_text')
    end

    def data_label(key)
      I18n.t(key.to_sym, scope: 'lib.college_readiness', default: I18n.db_t(key, default: key))
    end

    def data_label_info_text(key)
      I18n.t(key.to_sym, scope: 'lib.college_readiness.data_point_info_texts')
    end

    def included_data_types(cache = nil)
      config_for_cache = CHAR_CACHE_ACCESSORS.select { |c| cache.nil? || c[:cache] == cache }
      config_for_cache.map { |mapping| mapping[:data_key] }
    end

    def data_type_formatting_map
      @_data_type_to_value_type_map ||= (
        CHAR_CACHE_ACCESSORS.each_with_object({}) do |mapping, hash|
          hash[mapping[:data_key]] = mapping[:formatting]
        end
      )
    end

    def data_type_visualization_map
      @_data_type_visualization_map ||= (
        CHAR_CACHE_ACCESSORS.each_with_object({}) do |mapping, hash|
          hash[mapping[:data_key]] = mapping[:visualization]
        end
      )
    end

    def data_type_range_map
      @_data_type_range_map ||= (
      CHAR_CACHE_ACCESSORS.each_with_object({}) do |mapping, hash|
        hash[mapping[:data_key]] = mapping[:range] || (0..100)
      end
      )
    end

    def data_type_hashes
      hashes = school_cache_data_reader.characteristics_data(*included_data_types(:characteristics))
      enforce_same_year_school_value_for_data_types!(hashes, 'Average ACT score', 'ACT participation')
      enforce_same_year_school_value_for_data_types!(hashes, 'Average SAT score', 'SAT percent participation')
      hashes.merge!(school_cache_data_reader.gsdata_data(*included_data_types(:gsdata)))
      return [] if hashes.blank?
      hashes = hashes.map do |key, array|
        values = array.select do |h|
          # If it has no breakdown keys, that's good (gsdata)
          (!h.has_key?('breakdowns') && !h.has_key?('breakdown')) ||
          # otherwise the breakdown better be 'All students' (characteristics)
              h['breakdown'] == 'All students'
        end
        # This is for characteristics
        values = values.select { |h| !h.has_key?('subject') || h['subject'] == 'All subjects'}
        GSLogger.error(:misc, nil,
                       message:"Failed to find unique data point for data type #{key} in the characteristics/gsdata cache",
                       vars: {school: {state: @school_cache_data_reader.school.state,
                                       id: @school_cache_data_reader.school.id}
                       }) if values.size > 1
        hash = values.first
        hash['data_type'] = key if hash
        hash
      end
      hashes.compact.select(&with_school_values).sort_by { |o| included_data_types.index( o['data_type']) }
    end

    def school_value_present?(value)
      value.present? && value.to_s != '0.0' && value.to_s != '0'
    end

    def enforce_same_year_school_value_for_data_types!(hash, *data_types)
      data_type_hashes = hash.slice(*data_types).values.flatten.select do |tds|
        tds['subject'] == 'All subjects' && tds['breakdown'] == 'All students'
      end.flatten

      # first, find the max year for state data across the given data types
      max_year = data_type_hashes.map { |dts| dts['year'] }.max

      # Do all the data types have school data for that year?
      data_present_for_all_types = data_type_hashes.reduce(true) do |all_present, h|
        # The most recent year for one of the data types might be older,
        # so we have to read the school_value_xxxx property directly
        # to know whether each data type has school data for that year
        all_present && school_value_present?(h["school_value_#{max_year}"])
      end

      # If school data for most recent state isn't present across all the 
      # data types we need to remove the values, as that is the easiest way
      # to make sure they don't show up on the page
      unless data_present_for_all_types
        data_type_hashes.each do |h|
          h["school_value"] = nil
        end
      end
    end

    def data_values
      Array.wrap(data_type_hashes).map do |hash|
        data_type = hash['data_type']
        formatting = data_type_formatting_map[data_type]
        visualization = data_type_visualization_map[data_type]
        range = data_type_range_map[data_type]
        RatingScoreItem.new.tap do |item|
          item.label = data_label(data_type)
          item.info_text = data_label_info_text(data_type)
          item.score = SchoolProfiles::DataPoint.new(hash['school_value']).
            apply_formatting(*formatting)
          state_average = hash['state_average'] || hash['state_value']
          item.state_average = SchoolProfiles::DataPoint.new(state_average).
            apply_formatting(*formatting)
          item.visualization = visualization
          item.range = range
          item.year = hash['year'] || hash['source_year']
          item.source = hash['source'] || hash['source_name']
        end
      end
    end

    def sources
      content = '<div class="sourcing">'
      content << '<h1>' + data_label('title') + '</h1>'
      if rating_year.present?
        content << '<div>'
        content << '<h4>' + data_label('GreatSchools Rating') + '</h4>'
        content << '<p>' + data_label('Rating text') + '</p>'
        content << '<p><span class="emphasis">' + data_label('source') + '</span>: GreatSchools, ' + rating_year + '</p>'
        content << '</div>'
      end
      content << data_type_hashes.reduce('') do |string, hash|
        string << sources_for_view(hash)
      end
      content << '</div>'
    end

    def sources_for_view(hash)
      year = hash['year'] || hash['source_year']
      source = hash['source'] || hash['source_name']
      str = '<div>'
      str << '<h4>' + data_label(hash['data_type']) + '</h4>'
      str << "<p>#{data_label_info_text(hash['data_type'])}</p>"
      str << '<p><span class="emphasis">' + data_label('source')+ '</span>: ' + I18n.db_t(source, default: source) + ', ' + year.to_s + '</p>'
      str << '</div>'
      str
    end

    def rating_year
      @school_cache_data_reader.college_readiness_rating_year.to_s
    end

    def visible?
      data_values.present?
    end

    private

    def with_school_values
      ->(h) { h.has_key?('school_value') && h['school_value'].present? }
    end
  end
end
