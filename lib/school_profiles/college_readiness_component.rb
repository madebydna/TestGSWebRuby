module SchoolProfiles
  class CollegeReadinessComponent < CollegeReadiness
    class CharacteristicsValue
      include FromHashMethod
      module CollectionMethods
        def for_all_students
          select {|dv| dv.all_students?}.extend(CollectionMethods)
        end

        def having_school_value
          select {|dv| dv.school_value.present?}.extend(CollectionMethods)
        end

        def no_subject_or_all_subjects
          select {|h| h['subject'].nil? || h.all_subjects?}.extend(CollectionMethods)
        end

        def no_subject_or_all_subjects_or_graduates_remediation
          select do |h|
            h.subject.nil? || h.all_subjects? || h.is_a?(GraduatesRemediationValue)
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

        def having_most_recent_date
          max_year = map(&:year).compact.max
          select {|dv| dv.year == max_year}.extend(CollectionMethods)
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
        ['All subjects', 'Composite Subject', 'Not Applicable'].include?(subject)
      end

      def all_subjects_and_students?
        all_subjects? && all_students?
      end

      (2000..2030).to_a.each do |year|
        attr_accessor "school_value_#{year}"
        attr_accessor "state_average_#{year}"
        attr_accessor "district_average_#{year}"
        attr_accessor "performance_level_#{year}"
      end
    end

    module GraduatesRemediationValue
      def data_type
        if !all_subjects?
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
      config_for_cache = cache_accessor.select {|c| cache.nil? || c[:cache] == cache}
      config_for_cache.map {|mapping| mapping[:data_key]}
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

    def metrics_data
      array_of_hashes = @school_cache_data_reader.decorated_metrics_datas(*included_data_types(:metrics))
      array_of_hashes.each_with_object({}) do |(data_type, array), accum|
        accum[data_type] =
          if data_type == GRADUATES_REMEDIATION
            array.each { |dv| dv.extend(GraduatesRemediationValue) }
          else
            array
          end
      end
    end

    def data_type_hashes
      @_data_type_hashes ||= begin
        hashes = metrics_data
        hashes.merge!(@school_cache_data_reader.decorated_metrics_datas(*included_data_types(:gsdata)))
        return [] if hashes.blank?
        ActSatHandler.new(hashes).handle_ACT_SAT_to_display!
        hashes = hashes.map do |key, array|
          array = array.for_all_students.having_school_value.having_most_recent_date
          if array.respond_to?(:no_subject_or_all_subjects_or_graduates_remediation)
            # This is for metrics
            array = array.no_subject_or_all_subjects_or_graduates_remediation
          end
          array
        end

        data_values = hashes.flatten.compact
        data_values.select! {|dv| included_data_types.include?(dv['data_type'])}
        data_values.reject! {|dv| dv['year'].to_i < DATA_CUTOFF_YEAR} if cache_accessor == CHAR_CACHE_ACCESSORS_COLLEGE_SUCCESS
        data_values = select_post_secondary_max_year(data_values) if cache_accessor == CHAR_CACHE_ACCESSORS_COLLEGE_SUCCESS
        data_values.sort_by {|o| included_data_types.index(o['data_type'])}
      end
    end

    def select_post_secondary_max_year(data_values)
      post_secondary_data = data_values.select { | dv | POST_SECONDARY_GROUP_MAX_YEAR_FILTER.include?(dv['data_type']) }
      max_year = post_secondary_data.map(&:year).compact.max
      data_values.map do | dv |
        if POST_SECONDARY_GROUP_MAX_YEAR_FILTER.include?(dv['data_type'])
          dv['year'] == max_year ? dv : nil
        else
          dv
        end
      end.compact
    end

    def data_values
      @_data_values ||= Array.wrap(data_type_hashes).map do |hash|
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
      @_college_data_array ||= [{narration: narration, title: @tab.humanize, values: data_value_hash}]
    end

    def csa_badge?
      school_cache_data_reader.csa_badge?
    end

    def csa_awards
      school_cache_data_reader.csa_awards
    end

    def narration
      return nil unless visible?
      if @tab.to_sym == :college_success
        college_success_narration
      else
        if !rating.present? && !(1..10).cover?(rating.to_i)
          key = '_parent_tip_html'
        else
          key = '_' + ((rating / 2) + (rating % 2)).to_s + '_html'
        end
        I18n.t(key, scope: 'school_profiles.college_readiness.narration', default: key).html_safe if key
      end
    end

    def default_college_success_narration
      I18n.t('_college_success', scope: 'school_profiles.college_readiness.narration', default: '').html_safe
    end

    def college_success_narration
      return default_college_success_narration unless data_type_hashes.all? {|c| c.state_average.present?}

      narratives = data_type_hashes.map(&narration_for_value).compact

      return default_college_success_narration unless narratives.present?

      intro = I18n.t(:intro, scope: 'school_profiles.college_readiness.narration.college_success', default: '').html_safe
      outro = I18n.t(:outro, scope: 'school_profiles.college_readiness.narration.college_success', default: '',
                     end_more: SchoolProfilesController.show_more_end).html_safe

      "#{intro}#{narratives.first}#{SchoolProfilesController.show_more('College Success')}#{narratives.drop(1).join}#{outro}"
    end

    def narration_for_value
      lambda do |c|
        translation = I18n.t(c.data_type, scope: 'school_profiles.college_readiness.narration.college_success', default: nil)&.html_safe
        if translation.present? && c.school_value.present? && c.state_average.present?
          "<li>#{comparison_word(c.data_type, c.school_value, c.state_average)} #{translation}</li>"
        end
      end
    end

    def comparison_word(data_type, school_value, state_value)
      is_persistence = data_type == GRADUATES_PERSISTENCE
      diff = school_value - state_value
      if (diff).abs <= 2.0
        key = is_persistence ? :about : :average
      elsif diff > 0
        key = is_persistence ? :higher : :above_average
      else
        key = is_persistence ? :lower : :below_average
      end
      I18n.t(key, scope: 'school_profiles.college_readiness.narration.college_success', default: key.to_s).html_safe
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
      ->(h) {h['school_value'].present?}
    end
  end
end
