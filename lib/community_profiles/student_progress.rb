module CommunityProfiles
  class StudentProgress
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

    def sources
      cache_data = StateCache.for_state('ratings', state)&.cache_data
      source_info = cache_data.fetch("Student Progress Rating",[])
                              .sort_by {|x| x['year']}
                              .reverse
                              .first

      content = '<div class="sourcing">'
      content << '<h1>' + I18n.t('source_title', scope: "lib.student_progress.district_scope") + '</h1>'
      content << rating_source(year: source_info["year"], label: I18n.t('GreatSchools Rating', scope: "lib.student_progress"),
                               description: rating_db_label(source_info["description"]), methodology: nil,
                               more_anchor: 'studentprogressrating')
      content
    end

    def data_values
      return {} if total_schools(community_results_counts).zero?

      {}.tap do |h|
        h['key'] = 'student_progress'
        h['title'] = I18n.t('title', scope: "lib.student_progress.district_scope")
        h['subtext'] = I18n.t('subtext', scope: "lib.student_progress.district_scope")
        h['toc_item'] = I18n.t('toc_item', scope: "lib.student_progress.district_scope")
        h['narration'] = I18n.t("#{narration_logic}_html", scope: "lib.student_progress.district_scope.narrative")
        h['tooltip'] = I18n.t("tooltip_html", scope: "lib.student_progress.district_scope")
        h['graphic_header'] = I18n.t("graphic_header", scope: "lib.student_progress.district_scope")
        h['graphic_header_tooltip'] = I18n.t("graphic_header_tooltip", scope: "lib.student_progress.district_scope")
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

      community_results_percentages.map do |rating, percentage|
        {}.tap do |h|
          h['key'] = rating
          h['name'] = I18n.t(rating, scope: 'helpers.ratings_helpers')
          h['value_label'] = I18n.t("data_point_label", scope: "lib.student_progress.district_scope")
          h['district_value'] = SchoolProfiles::DataPoint.new(percentage).apply_formatting([:round]).format
          h['state_value'] = SchoolProfiles::DataPoint.new(state_results_percentages[rating]).apply_formatting([:round]).format
          h['color'] = colors[rating]
        end
      end
    end
  end
end