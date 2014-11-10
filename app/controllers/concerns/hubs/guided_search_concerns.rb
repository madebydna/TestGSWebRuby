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

        nav_helper = TopNav.new(@school, {}, @hub)

        set_omniture_data('GS:GuidedSchoolSearch', 'Search,Guided Search',nav_helper.topnav_title)
        set_meta_tags title:       "Your Personalized #{nav_helper.topnav_title} School Search | GreatSchools",
                      keywords:    "#{nav_helper.topnav_title} school wizard, #{nav_helper.topnav_title} schools,
                                    #{@state[:short].upcase} schools, #{nav_helper.topnav_title} school guided search",
                      description: "Use this 5-step guide to discover #{nav_helper.topnav_title} schools that match your
                                    child\'s unique needs and preferences including programs and extracurriculars, school
                                    focus areas, transportation, and daily schedules."

        render 'shared/guided_search'
      end
    else
      render 'error/page_not_found', layout: 'error', status: 404
    end
  end

end