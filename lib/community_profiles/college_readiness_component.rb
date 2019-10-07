module CommunityProfiles
  class CollegeReadinessComponent < CollegeReadiness
    class CharacteristicsValue
      include FromHashMethod
      module CollectionMethods
        def for_all_students
          select {|dv| dv.all_students?}.extend(CollectionMethods)
        end

        def having_district_value
          select {|dv| dv.district_value.present?}.extend(CollectionMethods)
        end

        def no_subject_or_all_subjects
          select {|h| h['subject'].nil? || h.all_subjects?}.extend(CollectionMethods)
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

        def having_most_recent_date
          max_year = map(&:year).compact.max
          select {|dv| dv.year == max_year}.extend(CollectionMethods)
        end
      end
      attr_accessor :breakdown, :original_breakdown, :district_value,
                    :year, :subject, :data_type, :source, :district_created, :subject_id, :subject,
                    :performance_level,  :narrative, :grade, :district_average, :state_average,
                    :state_value

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
        attr_accessor "district_value_#{year}"
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

    def initialize(tab, cache_data_reader)
      @tab = tab
      @cache_data_reader = cache_data_reader
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

    def characteristics_data
      array_of_hashes = @cache_data_reader.characteristics_data(*included_data_types(:characteristics))
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

    def gsdata_data
      @cache_data_reader.decorated_gsdata_datas(*included_data_types(:gsdata))
    end

    def multiple_breakdowns_in_one_data_type
      [SAT_PERCENT_COLLEGE_READY, ACT_PERCENT_COLLEGE_READY, SAT_PARTICIPATION, ACT_PARTICIPATION, ACT_SCORE, SAT_SCORE]
    end

    def data_types_in_the_overview
      [FOUR_YEAR_GRADE_RATE, SAT_PERCENT_COLLEGE_READY, ACT_PERCENT_COLLEGE_READY, SAT_PARTICIPATION, ACT_PARTICIPATION, ACT_SCORE, SAT_SCORE, AP_ENROLLED, AP_EXAMS_PASSED, SAT_PERCENT_COLLEGE_READY, DUAL_ENROLLMENT_PARTICIPATION, IB_PROGRAM_PARTICIPATION]
    end

    def college_success_datatypes
      POST_SECONDARY + REMEDIATION_SUBGROUPS + SECOND_YEAR
    end

    # Filters characteristics data from DB
    # these have been converted to instances of either CharacteristicsValue or GradutesRemediationValue 
    def data_type_hashes
      @_data_type_hashes ||= begin
        hashes = characteristics_data
        hashes.merge!(gsdata_data) if entity_type == 'district'
        return [] if hashes.blank?
        handle_ACT_SAT_to_display!(hashes)
        hashes = hashes.map do |key, array|
          if array.respond_to?(:no_subject_or_all_subjects_or_graduates_remediation)
            # This is for characteristics
            array = array.no_subject_or_all_subjects_or_graduates_remediation
          end
          array
        end
        data_values = hashes.flatten.compact
        data_values.select! { |dv| included_data_types.include?(dv['data_type']) }
        data_values.select! do |dv|
          if multiple_breakdowns_in_one_data_type.include?(dv['data_type']) && dv.subject != 'All subjects'
            false
          else
            true
          end
        end
        if @tab == "college_success"
          data_values.reject! {|dv| dv['year'].to_i < DATA_CUTOFF_YEAR} 
          data_values = select_post_secondary_max_year(data_values) 
        end
        data_values.sort_by {|o| included_data_types.index(o['data_type'])}
      end
    end

    def select_post_secondary_max_year(data_values)
      post_secondary_data = data_values.select { | dv | POST_SECONDARY.include?(dv['data_type']) }
      max_year = post_secondary_data.map(&:year).compact.max
      data_values.select do | dv |
        !POST_SECONDARY.include?(dv['data_type']) || dv['year'] == max_year 
      end
    end

    def data_values
      @_data_values ||= Array.wrap(data_type_hashes).map do |hash|
        data_type = hash['data_type']
        formatting = data_type_formatting_map[data_type] || [:round_unless_less_than_1, :percent]
        visualization = data_type_visualization_map[data_type]
        range = data_type_range_map[data_type]
        state = entity_type == 'district' ? @cache_data_reader.district.state : @cache_data_reader.state
        RatingScoreItem.new.tap do |item|
          item.label = data_label(data_type)
          item.data_type = data_type
          item.year = hash['year'] || ((hash['source_date_valid'] || '')[0..3]).presence || hash['source_year']
          item.subgroup = hash['breakdown']
          item.subgroup_percentage = breakdown_percentage(hash) if breakdown_percentage(hash)
          if data_type == SAT_SCORE
            item.info_text = data_label_info_text(sat_score_info_text_key(state, item.year))
            item.range = sat_score_range(state, item.year)
          else
            item.info_text = data_label_info_text(data_type)
            item.range = range
          end
          item.score = SchoolProfiles::DataPoint.new(hash["#{entity_type}_value"]).
            apply_formatting(*formatting)
          if entity_type != 'state'
            state_average = hash['state_average'] || hash['state_value']
            item.state_average = SchoolProfiles::DataPoint.new(state_average).
              apply_formatting(*formatting)
          end
          item.visualization = visualization
          item.source = hash['source'] || hash['source_name']
        end
      end.compact
    end

    def data_value_hash_overview
      # For the overview pane of the college readiness module
      @_data_value_hash_overview ||= data_values.map do |score_item|
        {label: score_item.score.format.to_s.chomp('%'),
         score: score_item.score.value.to_i,
         breakdown: score_item.label,
         data_type: score_item.data_type,
         subgroup: score_item.subgroup,
         state_average: score_item.state_average&.value.present? ? score_item.state_average.value.to_i : nil,
         state_average_label: score_item.state_average&.value.present? ? score_item.state_average.value.to_f.round.to_s : nil,
         display_type: score_item.visualization,
         lower_range: (score_item.range.first if score_item.range),
         upper_range: (score_item.range.last if score_item.range),
         tooltip_html: score_item.info_text
        }
      end
    end

    def data_value_hash
      # For the other pane of the college readiness module
      @_data_value_hash ||= data_values.map do |score_item|
        {label: score_item.score.format.to_s.chomp('%'),
         score: score_item.score.value.to_i,
         breakdown: I18n.t(score_item.subgroup, scope: 'lib.breakdowns'),
         percentage: score_item.subgroup_percentage,
         display_percentages: score_item.subgroup_percentage,
         data_type: score_item.data_type,
         subgroup: score_item.subgroup,
         state_average: score_item.state_average&.value.present? ? score_item.state_average.value.to_i : nil,
         state_average_label: score_item.state_average&.value.present? ? score_item.state_average.value.to_f.round.to_s : nil,
         display_type: score_item.visualization,
         lower_range: (score_item.range.first if score_item.range),
         upper_range: (score_item.range.last if score_item.range),
        }
      end
    end

    def college_data_array
      @_college_data_array ||= begin
        overview_data = data_value_hash_overview.select {|dv| data_types_in_the_overview.include?(dv[:data_type]) && dv[:subgroup] == 'All students'}
        uc_csu_data = sort_with_all_students_first(data_value_hash.select {|dv| dv[:data_type] == UC_CSU_ENTRANCE && EthnicityBreakdowns.ethnicity_breakdown?(dv[:subgroup]) })
        graduation_data = sort_with_all_students_first(data_value_hash.select {|dv| dv[:data_type] == FOUR_YEAR_GRADE_RATE && EthnicityBreakdowns.ethnicity_breakdown?(dv[:subgroup]) })
        college_success_data = data_value_hash_overview.select {|dv| college_success_datatypes.include?(dv[:data_type]) && dv[:subgroup] == 'All students'}
        # College readiness module - Data hashes to send to frontend
        data_array = []
        data_array << { narration: I18n.t('subtitle_html', scope: 'school_profiles.college_readiness'), title: I18n.t('Overview', scope: 'lib.equity_gsdata'), values: overview_data,  anchor: 'College readiness', type: 'mixed_variety'} if has_data?(overview_data)
        data_array << { narration: I18n.t('RE UC/CSU eligibility narration', scope: 'lib.equity_gsdata'), title: I18n.t('UC/CSU eligibility', scope: 'lib.equity_gsdata'), values: uc_csu_data, anchor: 'UC/CSU eligibility' } if has_data?(uc_csu_data)
        data_array << { narration: I18n.t('RE College readiness narration', scope: 'lib.equity_gsdata'), title: I18n.t('Graduation rates', scope: 'lib.equity_gsdata'), values: graduation_data, anchor: 'Graduation rates'} if has_data?(graduation_data)
        # no title for college success since we don't want the sub panels to render in React
        data_array << { narration: I18n.t('scoped_info_text', scope: 'lib.college_readiness', entity: I18n.t("#{entity_type}", scope: 'lib.college_readiness')), values: college_success_data, type: 'mixed_variety'} if has_data?(college_success_data)
        data_array.compact
      end
    end

    def has_data?(data)
      data.length > 0
    end

    def sort_with_all_students_first(student_hash)
      student_hash.sort_by! {|h| h[:subgroup]}
      index = student_hash.index {|h| h[:subgroup] == 'All students' }
      if index
        all_student = student_hash.delete_at(index)
        student_hash.unshift(all_student)
      end
      student_hash
    end

    def csa_badge?
      cache_data_reader.csa_badge?
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
        I18n.t(key, scope: 'lib.college_readiness.narration', default: key).html_safe if key
      end
    end

    def default_college_success_narration
      I18n.t('_college_success', scope: 'lib.college_readiness.narration', default: '').html_safe
    end

    def college_success_narration
      return default_college_success_narration unless data_type_hashes.all? {|c| c.state_average.present?}

      narratives = data_type_hashes.select{ |dh| dh["breakdown"] == 'All students'}.map(&narration_for_value).compact

      return default_college_success_narration unless narratives.present?

      intro = I18n.t(:district_intro, scope: 'lib.college_readiness.narration.college_success', default: '').html_safe
      outro = I18n.t(:outro, scope: 'lib.college_readiness.narration.college_success', default: '',
                     end_more: SchoolProfilesController.show_more_end).html_safe
      # "#{intro}#{narratives.first}#{SchoolProfilesController.show_more('College Success')}#{narratives.drop(1).join}#{outro}"
      "#{intro}#{narratives.join}#{outro}"
    end

    def narration_for_value
      lambda do |c|
        translation = I18n.t(c.data_type, scope: 'lib.college_readiness.narration.college_success', default: c.data_type).html_safe
        if translation.present? && c.district_value.present? && c.state_average.present?
          "<li>#{comparison_word(c.data_type, c.district_value, c.state_average)} #{translation}</li>"
        end
      end
    end

    def comparison_word(data_type, district_value, state_value)
      is_persistence = data_type == GRADUATES_PERSISTENCE
      diff = district_value - state_value
      if (diff).abs <= 2.0
        key = is_persistence ? :about : :average
      elsif diff > 0
        key = is_persistence ? :higher : :above_average
      else
        key = is_persistence ? :lower : :below_average
      end
      I18n.t(key, scope: 'lib.college_readiness.narration.college_success', default: key.to_s).html_safe
    end

    def empty_data?
      college_data_array.empty?
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

    def with_district_values
      ->(h) {h['district_value'].present?}
    end

    def breakdown_percentage(dv)
      value_to_s(ethnicities_to_percentages[dv.breakdown])
    end

    private

    def entity_type
      @_entity_type ||= begin
        if @cache_data_reader.is_a?(DistrictCacheDataReader)
          'district'
        elsif @cache_data_reader.is_a?(StateCacheDataReader)
          'state'
        else
          raise NotImplementedError.new("@cache_data_reader must be valid in #{self.class.name}#entity_type")
        end
      end
    end
  end
end
