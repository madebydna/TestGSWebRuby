module CommunityProfiles
  class AcademicProgress
    include Rails.application.routes.url_helpers
    include RatingSourceConcerns

    attr_reader :facet_results, :state_facet_results, :state_cache_data_reader

    def initialize(facet_results = {}, state_cache_data_reader)
      @facet_results = facet_results["community"]
      @state_facet_results = facet_results["state"]
      @state_cache_data_reader = state_cache_data_reader
    end

    def ratings_narration
      @_ratings_narration ||= CommunityProfiles::RatingsNarration.new(facet_results)
    end

    def state_ratings_narration
      @_state_ratings_narration ||= CommunityProfiles::RatingsNarration.new(state_facet_results)
    end

    def ratings_cache
      @_ratings_cache ||= state_cache_data_reader.ratings
    end

    def sources
      source_info = ratings_cache.fetch("Academic Progress Rating",[])
                                 .sort_by {|x| x['year']}
                                 .reverse
                                 .first

      content = '<div class="sourcing">'
      content << '<h1>' + I18n.t('source_title', scope: path_to_yml) + '</h1>'
      content << rating_source(year: source_info["year"], label: I18n.t('Greatschools rating', scope: "lib.academic_progress"),
                               description: rating_db_label(source_info["description"]), methodology: nil,
                               more_anchor: 'academicprogressrating',
                               state: @state_cache_data_reader.state.downcase)
      content
    end

    def data_values
      return {} if ratings_narration.total_counts.zero?

      {}.tap do |h|
        h['key'] = 'academic_progress'
        h['title'] = I18n.t('title', scope: path_to_yml)
        h['subtext'] = I18n.t('subtext', scope: path_to_yml)
        h['narration'] = I18n.t("#{ratings_narration.narration_logic}_html", scope: "lib.academic_progress.district_scope.narrative")
        h['tooltip'] = I18n.t("tooltip_html", scope: path_to_yml)
        h['graphic_header'] = I18n.t("graphic_header", scope: path_to_yml)
        h['graphic_header_tooltip'] = I18n.t("graphic_header_tooltip", scope: path_to_yml)
        h['data'] = data_points
        h['source'] = sources
      end
    end

    def path_to_yml
      'lib.academic_progress.district_scope'
    end

    # data points for the pie chart
    def data_points
      colors = {
        'above_average' => '#367A1E',
        'average' => '#8a720a',
        'below_average' => '#CB5C35'
      }

      ratings_narration.ratings_percentage_hash.map do |rating, percentage|
        {}.tap do |h|
          h['key'] = rating
          h['name'] = I18n.t(rating, scope: 'helpers.ratings_helpers')
          h['value_label'] = I18n.t("data_point_label", scope: path_to_yml)
          h['district_value'] = SchoolProfiles::DataPoint.new(percentage).apply_formatting([:round]).format
          h['state_value'] = SchoolProfiles::DataPoint.new(state_ratings_narration.ratings_percentage_hash[rating]).apply_formatting([:round]).format
          h['color'] = colors[rating]
        end
      end
    end
  end
end