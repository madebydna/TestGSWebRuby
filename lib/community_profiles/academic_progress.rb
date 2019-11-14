module CommunityProfiles
  class AcademicProgress
    include Rails.application.routes.url_helpers
    include FacetFieldsConcerns
    include RatingSourceConcerns

    attr_reader :facet_results, :state_facet_results, :state

    def initialize(facet_results = {}, state)
      @facet_results = facet_results["community"]
      @state_facet_results = facet_results["state"]
      @state = state
    end

    def ratings_narration
      @_ratings_narration ||= CommunityProfiles::RatingsNarration.new(facet_results)
    end

    def state_ratings_narration
      @_state_ratings_narration ||= CommunityProfiles::RatingsNarration.new(state_facet_results)
    end

    def sources
      cache_data = StateCache.for_state('ratings', state)&.cache_data
      source_info = cache_data.fetch("Academic Progress Rating",[])
                              .sort_by {|x| x['year']}
                              .reverse
                              .first

      content = '<div class="sourcing">'
      content << '<h1>' + I18n.t('source_title', scope: "lib.academic_progress.district_scope") + '</h1>'
      content << rating_source(year: source_info["year"], label: I18n.t('Greatschools rating', scope: "lib.academic_progress"),
                               description: rating_db_label(source_info["description"]), methodology: nil,
                               more_anchor: 'academicprogressrating')
      content
    end

    def data_values
      return {} if ratings_narration.total_counts.zero?
      
      {}.tap do |h|
        h['key'] = 'academic_progress'
        h['title'] = I18n.t('title', scope: "lib.academic_progress.district_scope")
        h['subtext'] = I18n.t('subtext', scope: "lib.academic_progress.district_scope")
        h['narration'] = I18n.t("#{ratings_narration.narration_logic}_html", scope: "lib.academic_progress.district_scope.narrative")
        h['tooltip'] = I18n.t("tooltip_html", scope: "lib.academic_progress.district_scope")
        h['graphic_header'] = I18n.t("graphic_header", scope: "lib.academic_progress.district_scope")
        h['graphic_header_tooltip'] = I18n.t("graphic_header_tooltip", scope: "lib.academic_progress.district_scope")
        h['data'] = data_points
        h['source'] = sources
      end
    end

    # data points for the pie chart
    def data_points
      colors = {
        'above_average' => '#367A1E',
        'average' => '#AB8F0E',
        'below_average' => '#CB5C35'
      }

      ratings_narration.ratings_percentage_hash.map do |rating, percentage|
        {}.tap do |h|
          h['key'] = rating
          h['name'] = I18n.t(rating, scope: 'helpers.ratings_helpers')
          h['value_label'] = I18n.t("data_point_label", scope: "lib.academic_progress.district_scope")
          h['district_value'] = SchoolProfiles::DataPoint.new(percentage).apply_formatting([:round]).format
          h['state_value'] = SchoolProfiles::DataPoint.new(state_ratings_narration.ratings_percentage_hash[rating]).apply_formatting([:round]).format
          h['color'] = colors[rating]
        end
      end
    end
  end
end