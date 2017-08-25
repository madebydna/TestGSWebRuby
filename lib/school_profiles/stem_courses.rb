module SchoolProfiles
  class StemCourses
    include Qualaroo

    attr_reader :school_cache_data_reader

    def initialize(school_cache_data_reader:)
      @school_cache_data_reader = school_cache_data_reader
    end

    def qualaroo_module_link
      qualaroo_iframe(:advanced_stem, @school_cache_data_reader.school.state, @school_cache_data_reader.school.id.to_s)
    end

    def data_types_and_visualizations
      {
          'Percentage algebra 1 enrolled grades 7-8' => :PersonBar,
          'Percentage passing algebra 1 grades 7-8' => :SingleBar,
          'Percentage AP math enrolled grades 9-12' => :SingleBar,
          'Percentage AP science enrolled grades 9-12' => :PersonBar
      }
    end

    def data_types
      data_types_and_visualizations.keys
    end

    def stem_data
      @_stem_data ||= @school_cache_data_reader.gsdata_data(*data_types)
    end

    def stem_courses_hashes
      stem_data.each_with_object([]) do |(data_type, bd_hashes), accum|
        bd_hashes.each do |bd_hash|
          data_value = GsdataCaching::GsDataValue.from_hash(bd_hash.merge(data_type: data_type))
          unless data_value.breakdowns.present? ## no breakdowns means "all students" in gsdata
            accum << {
                breakdown: I18n.t(data_type, scope: 'school_profiles.stem_courses', default:{})[:label],
                score: data_value.school_value.to_f,
                label: "#{data_value.school_value}",
                state_average: data_value.state_value.to_f,
                visualization: data_types_and_visualizations[data_type],
                tooltip_html: I18n.t(data_type, scope: 'school_profiles.stem_courses', default:{})[:tooltip_html]
            }
          end
        end
      end
    end

    def stem_courses_sources
      stem_data.each_with_object([]) do |(data_type, bd_hashes), accum|
        bd_hashes.each do |bd_hash|
          data_value = GsdataCaching::GsDataValue.from_hash(bd_hash.merge(data_type: data_type))
          unless data_value.breakdowns.present? ## no breakdowns means "all students" in gsdata
            accum << {
              data_type: I18n.t(data_type, scope: 'school_profiles.stem_courses', default:{})[:label],
              source_year: data_value.source_year,
              source_name: I18n.db_t(data_value.source_name)
            }
          end
        end
      end
    end

    def visible?
      stem_courses_hashes.present?
    end
  end
end
