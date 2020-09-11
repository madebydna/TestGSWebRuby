module CommunityProfiles
  class SummaryRating

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

    def summary_rating_type
      @_summary_rating_type ||= state_cache_data_reader.state_attribute('summary_rating_type')
    end

    def ratings
      @_ratings ||= state_cache_data_reader.ratings
    end

    def valid_date_in_words
      @_source_date_valid ||= begin
        cache_data = ratings.fetch(summary_rating_type, [])
        source_info = cache_data.sort_by {|x| x['year']}
                                .reverse
                                .first
        source_info&.fetch('date_in_word', nil)
      end
    end

    def path_to_yml
      if ['in', 'nd'].exclude?(@state_cache_data_reader.state.downcase)
        path = 'lib.summary_rating.district_scope_alt'
      else
        path = 'lib.summary_rating.district_scope'
      end
      path
    end

    def data_values
      return {} if ratings_narration.total_counts.zero?

      {}.tap do |h|
        h['key'] = 'summary_rating'
        h['title'] = I18n.t('title', scope: "lib.summary_rating.district_scope")
        h['subtext'] = I18n.t('subtext', scope: "lib.summary_rating.district_scope")
        h['narration'] = I18n.t("#{ratings_narration.narration_logic}_html", scope: "lib.summary_rating.district_scope.narrative")
        h['tooltip'] = I18n.t("tooltip_html", scope: path_to_yml)
        h['graphic_header'] = I18n.t("graphic_header", scope: "lib.summary_rating.district_scope")
        h['graphic_header_tooltip'] = I18n.t("graphic_header_tooltip", scope: "lib.summary_rating.district_scope")
        h['data'] = data_points
        h['source'] = I18n.t("source_html", scope: path_to_yml, date_in_words: valid_date_in_words)
      end
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
          h['value_label'] = I18n.t("data_point_label", scope: "lib.academic_progress.district_scope")
          h['district_value'] = SchoolProfiles::DataPoint.new(percentage).apply_formatting([:round]).format
          h['state_value'] = SchoolProfiles::DataPoint.new(state_ratings_narration.ratings_percentage_hash[rating]).apply_formatting([:round]).format
          h['color'] = colors[rating]
        end
      end
    end
  end
end