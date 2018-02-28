module SchoolProfiles


    class CollegeReadinessComponent < CollegeReadiness
      class CharacteristicsValue
        include FromHashMethod
        module CollectionMethods
          def for_all_students 
            select { |dv| dv.all_students? }.extend(CollectionMethods)
          end
          def having_school_value
            select { |dv| dv.school_value.present? }.extend(CollectionMethods)
          end
          def no_subject_or_all_subjects
            select { |h| h['subject'].nil? || h.all_subjects? }.extend(CollectionMethods)
          end
          def no_subject_or_all_subjects_or_graduates_remediation
            select do |h|
              h.subject.nil? || h.all_subjects? || h.is_a?(GradutesRemediationValue)
            end.extend(CollectionMethods)
          end
          def expect_only_one(message, other_helpful_vars = {})
            if size > 1
              GSLogger.error(
                :misc,
                nil,
                message: "Expected to find unique characteristics value: #{message}",
                vars: other_helpful_vars
              )
            end
            return first
          end
        end
        attr_accessor :breakdown, :original_breakdown, :school_value,
          :district_average, :state_average, :year, :subject, :data_type,
          :performance_level, :source, :created, :narrative, :grade

        def [](key)
          send(key) if respond_to?(key)
        end

        def []=(key, val)
          send("#{key}=", val)
        end

        def all_students?
          breakdown == 'All students'
        end

        def all_subjects?
          subject == 'All subjects'
        end

        (2000..2022).to_a.each do |year|
          attr_accessor "school_value_#{year}"
          attr_accessor "state_average_#{year}"
          attr_accessor "district_average_#{year}"
          attr_accessor "performance_level_#{year}"
        end
      end

      class GradutesRemediationValue < CharacteristicsValue
        def data_type
          if subject
            'Graduates needing ' + subject.capitalize + ' remediation in college'
          else
            @data_type
          end
        end
      end

      attr_reader :tab

      def initialize(tab, school_cache_data_reader)
        @tab = tab
        @school_cache_data_reader = school_cache_data_reader
      end

      def included_data_types(cache = nil)
        # Required for the sort in data_type_hashes
        config_for_cache = cache_accessor.select { |c| cache.nil? || c[:cache] == cache }
        config_for_cache.map { |mapping| mapping[:data_key] }
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

      def characteristics_data
        array_of_hashes = @school_cache_data_reader.characteristics_data(*included_data_types(:characteristics))
        array_of_hashes.each_with_object({}) do |(data_type, array), accum|
          accum[data_type] = 
            array.map do |h|
              klass = if data_type == GRADUATES_REMEDIATION
                        GradutesRemediationValue
                      else
                        CharacteristicsValue
                      end
              klass.from_hash(h.merge('data_type' => data_type))
            end
            .extend(CharacteristicsValue::CollectionMethods)
        end
      end

      def data_type_hashes
        @_data_type_hashes ||= (
        hashes = characteristics_data
        hashes.merge!(@school_cache_data_reader.decorated_gsdata_datas(*included_data_types(:gsdata )))
        return [] if hashes.blank?
        handle_ACT_SAT_to_display!(hashes)
        hashes = hashes.map do |key, array|
          array = array.for_all_students.having_school_value
          if array.respond_to?(:no_subject_or_all_subjects_or_graduates_remediation)
            # This is for characteristics
            array = array.no_subject_or_all_subjects_or_graduates_remediation
          end
          array
        end
        data_values = hashes.flatten.compact
        data_values.select! { |dv| included_data_types.include?(dv['data_type']) }
        data_values.sort_by { |o| included_data_types.index( o['data_type']) }
        )
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
           state_average: score_item.state_average.value.present? ? score_item.state_average.value.to_i : nil,
           state_average_label: score_item.state_average.value.present? ? score_item.state_average.value.to_f.round.to_s : nil,
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
        ->(h) { h['school_value'].present? }
      end
    end
end
