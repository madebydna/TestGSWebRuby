module SchoolProfiles
  class TeachersStaff

    attr_reader :school_cache_data_reader

    GSDATA_CACHE_ACCESSORS = [
        {
            :data_key => 'Ratio of students to full time teachers',
            :visualization => :ratio_viz,
            :formatting => [:to_f, :round]
        },
        {
            :data_key => 'Ratio of students to full time counselors',
            :visualization => :ratio_viz,
            :formatting => [:to_f, :round]
        },
        {
            :data_key => 'Percentage of teachers with less than three years experience',
            :visualization => :single_bar_viz_inverted,
            :formatting => [:to_f, :round, :percent]
        },
        {
            :data_key => 'Percentage of full time teachers who are certified',
            :visualization => :single_bar_viz,
            :formatting => [:to_f, :round, :percent]
        },
        {
            :data_key => 'Ratio of teacher salary to total number of teachers',
            :visualization => :dollar_viz,
            :formatting => [:to_f, :round, :dollars]
        }
    ].freeze

    def initialize(school_cache_data_reader)
      @school_cache_data_reader = school_cache_data_reader
    end

    def included_data_types
      @_included_data_types ||=
        GSDATA_CACHE_ACCESSORS.map { |mapping| mapping[:data_key] }
    end

    def data_type_formatting_map
      @_data_type_to_value_type_map ||= (
      GSDATA_CACHE_ACCESSORS.each_with_object({}) do |mapping, hash|
        hash[mapping[:data_key]] = mapping[:formatting]
      end
      )
    end

    def data_type_visualization_map
      @_data_type_visualization_map ||= (
      GSDATA_CACHE_ACCESSORS.each_with_object({}) do |mapping, hash|
        hash[mapping[:data_key]] = mapping[:visualization]
      end
      )
    end

    def data_type_range_map
      @_data_type_range_map ||= (
      GSDATA_CACHE_ACCESSORS.each_with_object({}) do |mapping, hash|
        hash[mapping[:data_key]] = mapping[:range] || (0..100)
      end
      )
    end

    def info_text
      I18n.t('lib.teachers_staff.info_text')
    end

    def visible?
      data_values.present?
    end

    def data_label(key)
      I18n.t(key.to_sym, scope: 'lib.teachers_staff', default: I18n.db_t(key, default: key))
    end

    def static_label(key)
      I18n.t(key, scope: 'lib.teachers_staff', default: key)
    end

    def data_label_info_text(key)
      I18n.t(key.to_sym, scope: 'lib.teachers_staff.data_point_info_texts', default: '')
    end

    def data_type_hashes
      hashes = school_cache_data_reader.gsdata_data(
          *included_data_types
      )
      return [] if hashes.blank?
      hashes = hashes.map do |key, array|
        GSLogger.error(:misc, nil,
                       message:"Failed to find unique data point for data type #{key} in the gsdata cache",
                       vars: {school: {state: @school_cache_data_reader.school.state,
                                       id: @school_cache_data_reader.school.id}
                       }) if array.size > 1
        hash = array.first
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
          item.score = SchoolProfiles::DataPoint.new(hash['school_value'].to_f).
              apply_formatting(*formatting)
          item.state_average = SchoolProfiles::DataPoint.new(hash['state_value']).
              apply_formatting(*formatting)
          item.visualization = visualization
          item.range = range
        end
      end
    end

    def sources
      content = '<div class="sourcing">'
      content << '<h1>' + static_label('title') + '</h1>'
      content << data_type_hashes.reduce('') do |string, hash|
        string << sources_for_view(hash)
      end
      content << '</div>'
    end

    def sources_for_view(hash)
      str = '<div>'
      str << '<h4>' + data_label(hash['data_type']) + '</h4>'
      str << "<p>#{data_label_info_text(hash['data_type'])}</p>"
      str << '<p><span class="emphasis">' + static_label('source')+ '</span>: ' + data_label(hash['source_name']) + ', ' + hash['source_year'].to_s + '</p>'
      str << '</div>'
      str
    end

  end
end

