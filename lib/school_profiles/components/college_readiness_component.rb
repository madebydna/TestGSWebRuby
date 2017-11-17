module SchoolProfiles
  module Components
    class CollegeReadinessComponent < CollegeReadiness
      attr_reader :tab

      def initialize(tab, school_cache_data_reader)
        @tab = tab
        @school_cache_data_reader = school_cache_data_reader
      end

      def included_data_types(cache = nil)
        # Required for the sort in data_type_hashes
        remediation_subgroups = REMEDIATION_SUBGROUPS
        config_for_cache = cache_accessor.select { |c| cache.nil? || c[:cache] == cache }
        config_for_cache.map { |mapping| mapping[:data_key] } + remediation_subgroups
      end

      def data_type_formatting_map
        cache_accessor.each_with_object({}) do |mapping, hash|
          hash[mapping[:data_key]] = mapping[:formatting]
        end
      end

      def data_type_visualization_map
        cache_accessor.each_with_object({}) do |mapping, hash|
          hash[mapping[:data_key]] = mapping[:visualization]
        end
      end

      def data_type_range_map
        cache_accessor.each_with_object({}) do |mapping, hash|
          hash[mapping[:data_key]] = mapping[:range] || (0..100)
        end
      end

      def data_type_hashes
        @_data_type_hashes ||= (
        hashes = @school_cache_data_reader.characteristics_data(*included_data_types( :characteristics ))
        hashes.merge!(@school_cache_data_reader.gsdata_data(*included_data_types(:gsdata )))
        return [] if hashes.blank?
        handle_ACT_SAT_to_display!(hashes)
        hashes = hashes.map do |key, array|
          values = array.select do |h|
            # If it has no breakdown keys, that's good (gsdata)
            (!h.has_key?('breakdowns') && !h.has_key?('breakdown')) ||
              # otherwise the breakdown better be 'All students' (characteristics)
              h['breakdown'] == 'All students'
          end
          # This is for characteristics

          unless key == GRADUATES_REMEDIATION
            values = values.select { |h| !h.has_key?('subject') || h['subject'] == 'All subjects'}
            GSLogger.error(:misc, nil,
                           message:"Failed to find unique data point for data type #{key} in the characteristics/gsdata cache",
                           vars: {school: {state: @school_cache_data_reader.school.state,
                                           id: @school_cache_data_reader.school.id}
                           }) if values.size > 1
          end
          add_data_type(key,values)
        end
        data_values = hashes.flatten.compact.select(&with_school_values)
        data_values.select! { |dv| included_data_types.include?(dv['data_type']) }
        data_values.sort_by { |o| included_data_types.index( o['data_type']) }
        )
      end

      def add_data_type(key,values)
        # Special handling for Remediation data, which is organized by subject
        if key == CollegeReadiness::GRADUATES_REMEDIATION
          arr = values.map do |hash|
            if hash.has_key?('subject')
              hash.merge('data_type' => 'Graduates needing ' + hash['subject'].capitalize + ' remediation in college')
            else
              hash.merge('data_type' => key)
            end
          end
          arr
        else
          hash = values.first
          hash['data_type'] = key if hash
          hash
        end
      end

      def data_values
        @_data_values ||= Array.wrap(data_type_hashes).map do |hash|
          next if cache_accessor == CHAR_CACHE_ACCESSORS_COLLEGE_SUCCESS && hash['year'].to_i < DATA_CUTOFF_YEAR
          data_type = hash['data_type']
          formatting = data_type_formatting_map[data_type] || [:round_unless_less_than_1, :percent]
          visualization = data_type_visualization_map[data_type]
          range = data_type_range_map[data_type]
          state = @school_cache_data_reader.school.state
          RatingScoreItem.new.tap do |item|
            item.label = data_label(data_type)
            item.year = hash['year'] || ((hash['source_date_valid'] || '')[0..3]).presence || hash['source_year']
            if data_type == SAT_SCORE
              item.info_text = data_label_info_text(sat_score_info_text_key(state, item.year))
              item.range = sat_score_range(state, item.year)
            else
              item.info_text = data_label_info_text(data_type)
              item.range = range
            end
            item.score = SchoolProfiles::DataPoint.new(hash['school_value']).
              apply_formatting(*formatting)
            state_average = hash['state_average'] || hash['state_value']
            item.state_average = SchoolProfiles::DataPoint.new(state_average).
              apply_formatting(*formatting)
            item.visualization = visualization
            item.source = hash['source'] || hash['source_name']
          end
        end.compact
      end

      def data_value_hash
        @_data_value_hash ||= data_values.map do |score_item|
          {label: score_item.score.format.to_s.chomp('%'),
           score: score_item.score.value.to_i,
           breakdown: score_item.label,
           state_average: score_item.state_average.value.to_i,
           state_average_label: score_item.state_average.value.to_f.round.to_s,
           display_type: score_item.visualization,
           lower_range: (score_item.range.first if score_item.range),
           upper_range: (score_item.range.last if score_item.range),
           tooltip_html: score_item.info_text
          }
        end
      end

      def college_data_array
        [{narration: narration, title: @tab.humanize, values: data_value_hash}]
      end

      def narration
        if !rating.present? && !(1..10).cover?(rating.to_i) && visible?
          key = '_parent_tip_html'
        elsif !visible?
          return nil
        elsif @tab.to_sym == :college_success
          key = '_college_success'
        elsif @tab.to_sym == :college_readiness
          key = '_' + ((rating / 2) + (rating % 2)).to_s + '_html'
        end
        I18n.t(key, scope: 'lib.college_readiness.narration', default: I18n.db_t(key, default: key)).html_safe
      end

      def empty_data?
        college_data_array[0][:values].empty?
      end

      def cache_accessor
        @_cache_accessor ||= CollegeReadiness::TABS[@tab]
      end

      def visible?
        data_values.present?
      end

      def scope
        @_scope ||= 'school_profiles.' + @tab
      end

      def with_school_values
        ->(h) { h.has_key?('school_value') && h['school_value'].present? }
      end
    end
  end
end
