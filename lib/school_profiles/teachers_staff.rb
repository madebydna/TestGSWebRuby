module SchoolProfiles
  class TeachersStaff
    include Qualaroo
    include SharingTooltipModal

    attr_reader :school_cache_data_reader

    THREE_YEARS_EXPERIENCE ='Percentage of teachers with less than three years experience'

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
            :data_key => THREE_YEARS_EXPERIENCE,
            :visualization => :single_bar_viz_inverted,
            :formatting => [:to_f, :invert_using_one_hundred, :round, :percent]
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
        },
        {
          :data_key => 'Nurse indicator',
          :visualization => :plain_text_viz,
          :formatting => [:employment_level]
        },
        {
          :data_key => 'Psychologist indicator',
          :visualization => :plain_text_viz,
          :formatting => [:employment_level]
        },
        {
          :data_key => 'Social Worker indicator',
          :visualization => :plain_text_viz,
          :formatting => [:employment_level]
        },
        {
            :data_key => 'Law Enforcement Officer indicator',
            :visualization => :plain_text_viz,
            :formatting => [:employment_level]
        },
        {
            :data_key => 'Security Guard indicator',
            :visualization => :plain_text_viz,
            :formatting => [:employment_level]
        },
    ].freeze

    def initialize(school_cache_data_reader)
      @school_cache_data_reader = school_cache_data_reader
    end

    def share_content
      share_tooltip_modal('Teachers_staff', @school_cache_data_reader.school)
    end

    def qualaroo_module_link
      qualaroo_iframe(:teachers_staff, @school_cache_data_reader.school.state, @school_cache_data_reader.school.id.to_s)
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
    
    def data_score_type(obj, formatting)
      if formatting.include?(:employment_level)
        return employment_level(obj.school_value.to_f, obj.breakdowns)
      end
      SchoolProfiles::DataPoint.new(obj.school_value.to_f).apply_formatting(*formatting)
    end

    def employment_level(value, breakdowns)
      presence = {
        0.0 => 'not_present',
        1.0 => 'present'
      }
      t_presence = presence[value]
      t_key = breakdowns.first

      I18n.t("lib.teachers_staff.employment_level.#{t_presence}.#{t_key}")
    end

    def data_values_by_data_type
      hashes = school_cache_data_reader.gsdata_data(
          *included_data_types
      )
      return [] if hashes.blank?
      objs = hashes.map do |key, array|
        values = GsdataCaching::GsDataValue.from_array_of_hashes(array.map { |h| h.merge(data_type: key) })
        values.having_most_recent_date.first
      end
      objs.sort_by { |o| included_data_types.index(o.data_type) }
    end

    def data_values
      Array.wrap(data_values_by_data_type).map do |obj|
        data_type = obj.data_type
        formatting = data_type_formatting_map[data_type]
        visualization = data_type_visualization_map[data_type]
        range = data_type_range_map[data_type]
        RatingScoreItem.new.tap do |item|
          item.label = data_label(data_type)
          item.info_text = data_label_info_text(data_type)
          item.score = data_score_type(obj, formatting)
          item.state_average = SchoolProfiles::DataPoint.new(obj.state_value).
              apply_formatting(*formatting)
          item.visualization = visualization
          item.range = range
        end
      end
    end

    def sources
      content = '<div class="sourcing">'
      content << '<h1>' + static_label('title') + '</h1>'
      content << data_values_by_data_type.reduce('') do |string, data_value|
        string << sources_text(data_value)
      end
      content << '</div>'
    end

    def sources_text(data_value)
      str = '<div>'
      str << '<h4>' + data_label(data_value.data_type) + '</h4>'
      str << "<p>#{data_label_info_text(data_value.data_type)}</p>"
      str << '<p><span class="emphasis">' + static_label('source')+ '</span>: ' + data_label(data_value.source_name) + ', ' + data_value.source_year.to_s + '</p>'
      str << '</div>'
      str
    end

  end
end

