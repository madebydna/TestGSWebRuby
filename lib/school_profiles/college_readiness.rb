module SchoolProfiles
  class CollegeReadiness
    attr_reader :school_cache_data_reader

    # Order matters - items display in configured order
    CHAR_CACHE_ACCESSORS = [
      {
        :cache => :characteristics,
        :data_key => '4-year high school graduation rate',
        :visualization => :person_bar_viz,
        :formatting => [:round, :percent]
      },
      {
        :cache => :characteristics,
        :data_key => 'Percent of students who meet UC/CSU entrance requirements',
        :visualization => :single_bar_viz,
        :formatting => [:round, :percent]
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
        :formatting => [:round, :percent]
      },
      {
        :cache => :characteristics,
        :data_key => 'Average ACT score',
        :visualization => :single_bar_viz,
        :formatting => [:round],
        :range => (1..36)
      },
      {
        :cache => :gsdata,
        :data_key => 'Percentage AP enrolled grades 9-12',
        :visualization => :person_bar_viz,
        :formatting => [:to_f, :round, :percent]
      },
      {
        :cache => :gsdata,
        :data_key => 'Percentage of students passing 1 or more AP exams grades 9-12',
        :visualization => :single_bar_viz,
        :formatting => [:to_f, :round, :percent]
      }
    ].freeze

    def initialize(school_cache_data_reader:)
      @school_cache_data_reader = school_cache_data_reader
    end

    def rating
      ((1..10).to_a & [@school_cache_data_reader.college_readiness_rating]).first
    end

    def info_text
      I18n.t('lib.college_readiness.info_text')
    end

    def data_label(key)
      key.to_sym
      I18n.t(key.to_sym, scope: 'lib.college_readiness', default: key)
    end

    def data_label_info_text(key)
      key.to_sym
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
        hash['data_type'] = key
        hash
      end
      hashes.sort_by { |o| included_data_types.index( o['data_type']) }
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
        end
      end
    end

    def visible?
      data_values.present?
    end
  end
end
