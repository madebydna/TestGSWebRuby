module SchoolProfiles
  class StemCourses

    attr_reader :school, :school_cache_data_reader

    def initialize(school, school_cache_data_reader:)
      @school = school
      @school_cache_data_reader = school_cache_data_reader
    end

    def data_types_and_visualizations
      {
          'Percentage algebra 1 enrolled grades 7-8' => :person_bar_viz,
          'Percentage passing algebra 1 grades 7-8' => :single_bar_viz,
          'Percentage AP math enrolled grades 9-12' => :person_bar_viz,
          'Percentage AP science enrolled grades 9-12' => :person_bar_viz

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
          unless bd_hash.has_key?('breakdowns') ## no breakdowns means "all students" in gsdata
            accum << {
                data_type: data_type,
                school_value: bd_hash['school_value'],
                state_value: bd_hash['state_value'],
                visualization: data_types_and_visualizations[data_type]
            }
          end
        end
      end
    end

    def stem_courses_sources
      stem_data.each_with_object([]) do |(data_type, bd_hashes), accum|
        bd_hashes.each do |bd_hash|
          unless bd_hash.has_key?('breakdowns') ## no breakdowns means "all students" in gsdata
            accum << {
                data_type: data_type,
                source_year: bd_hash['source_year'],
                source_name: bd_hash['source_name']
            }
          end
        end
      end
    end

  end
end
