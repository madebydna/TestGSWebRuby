module CommunityProfiles
  class AcademicProgress
    include FacetFieldsConcerns

    def initialize(facet_results = [], state_facet_results = [])
      @facet_results = facet_results
      @state_facet_results = state_facet_results
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
      return {} if total_schools(community_results_counts).zero?

      {}.tap do |h|
        h['title'] = I18n.t('title', scope: "lib.academic_progress.district_scope")
        h['subtext'] = I18n.t('subtext', scope: "lib.academic_progress.district_scope")
        h['narration'] = I18n.t("#{narration_logic}_html", scope: "lib.academic_progress.district_scope.narrative")
        h['tooltips'] = I18n.t("tooltip_html", scope: "lib.academic_progress.district_scope")
        h['graphic_header'] = I18n.t("graphic_header", scope: "lib.academic_progress.district_scope")
        h['graphic_header_tooltip'] = I18n.t("graphic_header_tooltip", scope: "lib.academic_progress.district_scope")
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
  end
end