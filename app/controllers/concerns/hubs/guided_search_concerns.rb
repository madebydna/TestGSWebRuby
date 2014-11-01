module GuidedSearchConcerns

  extend ActiveSupport::Concern

  protected

  def render_guided_search
    if @hub and has_guided_search?

      if @hub.nil?
        render 'error/page_not_found', layout: 'error', status: 404
      else
        @collection_id = @hub.collection_id
        # @canonical_url = state_guided_search_url(hub_city_mapping)
        @guided_search_tab=['get_started','child_care','dress_code','school_focus','class_offerings']
        gon.state_abbr = @state[:short]

        set_omniture_data('GS:GuidedSchoolSearch', 'Search,Guided Search',@state[:long].titleize)
        set_meta_tags title:       "Your Personalized #{@state[:long].titleize} School Search | GreatSchools",
                      description: "#{@state[:long].titleize} school wizard, #{@state[:long].titleize} schools,
                                  #{@state[:short].upcase} schools, #{@state[:short].upcase} school guided search",
                      keywords:    "Use this 5-step guide to discover #{@state[:long].titleize} schools that match your
                                 child\'s unique needs and preferences including programs and extracurriculars, school
                                 focus areas, transportation, and daily schedules."

        render 'shared/guided_search'
      end
    else
      render 'error/page_not_found', layout: 'error', status: 404
    end
  end

end