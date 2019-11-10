module CommunityProfiles
  class SummaryRating
    include Rails.application.routes.url_helpers
    include FacetFieldsConcerns
    include RatingSourceConcerns

    attr_reader :facet_results, :state_facet_results, :state

    def initialize(facet_results = {}, state)
      @facet_results = facet_results["community"]
      @state_facet_results = facet_results["state"]
      @state = state
    end

    def community_results_counts
      @_community_results_counts ||=begin
        school_counts(facet_results)
      end
    end

    def community_results_percentages
      @_community_results_percentages ||=begin
        convert_to_percentage_hash(community_results_counts)
      end
    end

    def state_results_counts
      @_state_results_counts ||=begin
        school_counts(state_facet_results)
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
        h['key'] = 'summary_rating'
        h['title'] = I18n.t('title', scope: "lib.summary_rating.district_scope")
        h['subtext'] = I18n.t('subtext', scope: "lib.summary_rating.district_scope")
        h['narration'] = I18n.t("#{narration_logic}_html", scope: "lib.summary_rating.district_scope.narrative")
        h['tooltip'] = I18n.t("tooltip_html", scope: "lib.summary_rating.district_scope")
        h['graphic_header'] = I18n.t("graphic_header", scope: "lib.summary_rating.district_scope")
        h['graphic_header_tooltip'] = I18n.t("graphic_header_tooltip", scope: "lib.summary_rating.district_scope")
        h['data'] = data_points
      end
    end

    # data points for the pie chart
    def data_points
      colors = {
        'above_average' => '#367A1E',
        'average' => '#AB8F0E',
        'below_average' => '#CB5C35'
      }

      community_results_percentages.map do |rating, percentage|
        {}.tap do |h|
          h['key'] = rating
          h['name'] = I18n.t(rating, scope: 'helpers.ratings_helpers')
          h['value_label'] = I18n.t("data_point_label", scope: "lib.academic_progress.district_scope")
          h['district_value'] = SchoolProfiles::DataPoint.new(percentage).apply_formatting([:round]).format
          h['state_value'] = SchoolProfiles::DataPoint.new(state_results_percentages[rating]).apply_formatting([:round]).format
          h['color'] = colors[rating]
        end
      end
    end
  end
end