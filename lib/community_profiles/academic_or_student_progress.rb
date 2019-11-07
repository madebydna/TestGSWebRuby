module CommunityProfiles
  class AcademicOrStudentProgress
    BELOW_AVERAGE = %w(1 2 3 4)
    AVERAGE = %w(5 6)
    ABOVE_AVERAGE = %w(7 8 9 10)
    BELOW_AVERAGE_KEY = 'below_average'
    AVERAGE_KEY = 'average'
    ABOVE_AVERAGE_KEY = 'above_average'
    RATINGS_KEYS_ARRAY = [BELOW_AVERAGE_KEY, AVERAGE_KEY, ABOVE_AVERAGE_KEY]
    STUDENT_PROGRESS = 'student_progress'
    ACADEMIC_PROGRESS = 'academic_progress'
    GROWTH_TYPES = [STUDENT_PROGRESS, ACADEMIC_PROGRESS]
    
    attr_reader :growth_type

    def initialize(growth_type, facet_results = [], state_facet_results = [])
      @facet_results = facet_results
      @state_facet_results = state_facet_results
      @growth_type = growth_type
    end

    def community_results_counts
      @_community_results_counts ||=begin
        school_counts(@facet_results)
      end
    end

    def community_results_percentages
      @_community_results_percentages ||=begin
        convert_to_percentage_hash(community_results_counts)
      end
    end

    def state_results_counts
      @_state_results_counts ||=begin
        school_counts(@state_facet_results)
      end
    end

    def state_results_percentages
      @_state_results_percentages ||=begin
        convert_to_percentage_hash(state_results_counts)
      end
    end

    def data_values
      return {} if growth_type == 'N/A' || total_schools(community_results_counts).zero?
      raise ArgumentError.new("Wrong type of #{growth_type} supplied to initializer") unless GROWTH_TYPES.include?(growth_type)

      {}.tap do |h|
        h['title'] = I18n.t('title', scope: "lib.#{growth_type}.district_scope")
        h['subtext'] = I18n.t('subtext', scope: "lib.#{growth_type}.district_scope")
        h['narration'] = I18n.t("#{narration_logic}_html", scope: "lib.#{growth_type}.district_scope.narrative")
        h['tooltips'] = I18n.t("tooltip_html", scope: "lib.#{growth_type}.district_scope")
        h['graphic_header'] = I18n.t("graphic_header", scope: "lib.#{growth_type}.district_scope")
        h['graphic_header_tooltip'] = I18n.t("graphic_header_tooltip", scope: "lib.#{growth_type}.district_scope")
        h['data'] = data_points
      end
    end

    # data points for the pie chart
    def data_points
      community_results_percentages.map do |rating, percentage|
        {}.tap do |h|
          h['key'] = rating
          h['title'] = I18n.t(rating, scope: 'helpers.ratings_helpers')
          h['percentage'] = SchoolProfiles::DataPoint.new(percentage).apply_formatting([:percent]).format
          h['state_average'] = SchoolProfiles::DataPoint.new(state_results_percentages[rating]).apply_formatting([:percent]).format
        end
      end
    end

    private

    def range
      community_results_percentages.values.max - community_results_percentages.values.min
    end

    def narration_logic
      top_two_ratings_by_percentage_array = 
        community_results_percentages.sort_by {|rating, percentage| percentage}
                                     .reverse
                                     .first(2)
      return 'even_distribution' if range < 4 || top_two_ratings_by_percentage_array.first[1] == top_two_ratings_by_percentage_array.last[1]
      
      top_two_ratings_by_percentage_array.first[0]
    end

    def convert_to_percentage_hash(result_set)
      RATINGS_KEYS_ARRAY.each_with_object({}) do |key, hash|
        hash[key] = ((result_set[key].to_f / total_schools(result_set)) * 100).round
      end
    end

    def total_schools(result_set)
      result_set.values.reduce(:+) || 0
    end

    def school_counts(facet_results)
      result_set = Hash.new(0)

      facet_results.each_slice(2) do |score, count|
        if BELOW_AVERAGE.include?(score)
          result_set[BELOW_AVERAGE_KEY] += count
        elsif AVERAGE.include?(score)
          result_set[AVERAGE_KEY] += count
        elsif ABOVE_AVERAGE.include?(score)
          result_set[ABOVE_AVERAGE_KEY] += count
        else
          GSLogger.error(:community_profiles, nil, message:"facet fields returned invalid score for #{self.class}", vars: school) if log_error?(helper_name, params_hash)
          raise StandardError.new("facet fields returned invalid score for #{self.class}")
        end
      end

      result_set
    end
  end
end