class GuidedSearchController < ApplicationController
  include HubConcerns

  before_action :set_city_state
  before_action :set_hub
  before_action :add_collection_id_to_gtm_data_layer
  before_action :set_login_redirect

  def show
    if @hub and has_guided_search?
      if @hub.nil?
        render 'error/page_not_found', layout: 'error', status: 404
      else
        @collection_id = @hub.collection_id
        @guided_search_tab = ['get_started','child_care','dress_code','school_focus','class_offerings']
        gon.state_abbr = @state[:short]

        nav_helper = TopNav.new(@school, {}, @hub)

        gon.pagename = 'GS:GuidedSchoolSearch'
        set_meta_tags(
          title: "Your Personalized #{nav_helper.topnav_title} School Search | GreatSchools",
          description: "Use this 5-step guide to discover #{nav_helper.topnav_title} schools that match your
                        child\'s unique needs and preferences including programs and extracurriculars, school
                        focus areas, transportation, and daily schedules."
        )
      end
    else
      if @city
        redirect_to city_url(gs_legacy_url_encode(@state[:long]), gs_legacy_url_encode(@city))
      else
        redirect_to state_url(gs_legacy_url_encode(@state[:long]))
      end
    end
  end
end
