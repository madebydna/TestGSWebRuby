class StatesController < ApplicationController
  include SeoHelper
  include MetaTagsHelper
  include HubConcerns
  include GuidedSearchConcerns

  before_action :set_city_state
  before_action :set_hub
  before_action :set_login_redirect
  before_action :set_footer_cities
  before_action :write_meta_tags, only: [:show, :community]
  before_action :set_state_home_omniture_data, only: [:show]

  def show
    if @hub.nil?
      state_home
    else
      collection_id = @hub.collection_id
      configs = hub_configs(collection_id)

      @hub.has_guided_search?

      @collection_nickname = CollectionConfig.collection_nickname(configs)
      @content_modules = CollectionConfig.content_modules(configs)
      @sponsor = CollectionConfig.sponsor(configs, :state)
      @browse_links = CollectionConfig.browse_links(configs)
      @partners = CollectionConfig.state_partners(configs)
      @choose_school = CollectionConfig.state_choose_school(configs)
      @articles = CollectionConfig.state_featured_articles(configs)
      @hero_image = "hubs/desktop/#{collection_id}-#{@state[:short].upcase}_hero.jpg"
      @hero_image_mobile  = "hubs/small/#{collection_id}-#{@state[:short].upcase}_hero_small.jpg"
      @canonical_url = state_url(gs_legacy_url_encode(@state[:long]))
      @show_ads = CollectionConfig.show_ads(configs)
      @important_events = CollectionConfig.city_hub_important_events(configs)
      @announcement = CollectionConfig.city_hub_announcement(configs)
      gon.state_abbr = @state[:short]

      ad_setTargeting_through_gon

    end
  end

  def state_home
    @params_hash = parse_array_query_string(request.query_string)
    gon.state_abbr = @state[:short]
    @ad_page_name = :State_Home_Standard
    @show_ads = PropertyConfig.advertising_enabled?
    gon.show_ads = show_ads?
    ad_setTargeting_through_gon
    render 'states/state_home'
  end

  def choosing_schools
    if @hub.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      @collection_id = @hub.collection_id
      configs = hub_configs(@collection_id)

      set_meta_tags title: "Choosing a school in #{@state[:long].titleize}"
      @collection_nickname = CollectionConfig.collection_nickname(configs)
      @events = CollectionConfig.city_hub_important_events(configs)
      @step3_links = CollectionConfig.choosing_page_links(configs)
      @step3_search_links = CollectionConfig.choosing_page_search_links(configs)
      @breadcrumbs = {
        @state[:long].titleize => state_path(params[:state]),
        'Choosing a School' => nil
      }
      @canonical_url = state_choosing_schools_url(params[:state])
      gon.state_abbr = @state[:short]

      set_omniture_data('GS:State:ChoosingSchools', 'Home,StateHome,ChoosingSchools',@state[:long].titleize)
      set_meta_tags title:       "Choosing a school in #{@state[:long].titleize}",
                    description: " Five simple steps to help parents choose a school in #{@state[:long].titleize}",
                    keywords:    "choose a #{@state[:long].titleize} school, choosing #{@state[:long].titleize} schools,
                                  school choice #{@state[:long].titleize}, #{@state[:long].titleize} school choice tips,
                                  #{@state[:long].titleize} school choice steps"
      render 'shared/choosing_schools'
    end
  end

  def events
    if @hub.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      @collection_id = @hub.collection_id
      collection_configs = hub_configs(@collection_id)
      @collection_nickname = CollectionConfig.collection_nickname(collection_configs)
      @events = CollectionConfig.important_events(@collection_id)
      @breadcrumbs = {
          @state[:long].titleize => state_path(params[:state]),
          'Events' =>nil
      }
      @canonical_url = state_events_url(params[:state])
      gon.state_abbr = @state[:short]


      set_omniture_data('GS:State:Events', 'Home,StateHome,Events',@state[:long].titleize)
      set_meta_tags title:       "Education Events in  #{@state[:long].titleize}",
                    description: "Key #{@state[:long].titleize} dates and events to mark on your calendar",
                    keywords:    "#{@state[:long].titleize} school system events, #{@state[:long].titleize}
                                  public schools events, #{@state[:long].titleize} school system dates,
                                  #{@state[:long].titleize} public schools dates, #{@state[:long].titleize} school
                                  system calendar, #{@state[:long].titleize} public schools calendar"
      render 'shared/events'

    end
  end

  def guided_search
    render_guided_search
  end

  def enrollment
    if @hub.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      @collection_id = @hub.collection_id
      configs = hub_configs(@collection_id)
      @collection_nickname = CollectionConfig.collection_nickname(configs)
      @events = nil # stub

      # TODO: if you don't show browse links, don't make this call, #hack
      @tab = CollectionConfig.enrollment_tabs(@state[:short], @collection_id, params[:tab])
      [:public, :private].each do |type|
        @tab[:results][type] = {} if @tab[:results][type].nil?
        @tab[:results][type][:count] = 0
      end

      @subheading = CollectionConfig.enrollment_subheading(configs)

      @enrollment_module = CollectionConfig.enrollment_module(configs, @tab[:key])
      @tips = CollectionConfig.enrollment_tips(configs, @tab[:key])

      @key_dates = CollectionConfig.key_dates(configs, @tab[:key])

      set_meta_tags title: "#{@state[:long].titleize} Schools Enrollment Information"
      @breadcrumbs = {
        @state[:long].titleize => state_path(params[:state]),
        'Enrollment Information' => nil
      }

      @canonical_url = state_enrollment_url(params[:state])
      gon.state_abbr = @state[:short]

      set_omniture_data('GS:State:Enrollment', 'Home,StateHome,Enrollment',@state[:long].titleize)
      set_meta_tags title:       "#{@state[:long].titleize} Schools Enrollment Information",
                    description: " Practical information including rules, deadlines and tips, for enrolling your child
                                   in #{@state[:long].titleize}  schools",
                    keywords:    "#{@state[:long].titleize}  school enrollment, #{@state[:long].titleize}  school
                                  enrollment information, #{@state[:long].titleize} school enrollment info,
                                  #{@state[:long].titleize} school enrollment process, #{@state[:long].titleize} school
                                   enrollment deadlines"


      render 'shared/enrollment'
    end
  end

  def community
    if @hub.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      @collection_id = @hub.collection_id
      collection_configs = hub_configs(@collection_id)

      set_community_tab(collection_configs)
      set_community_omniture_data

      @collection_nickname = CollectionConfig.collection_nickname(collection_configs)
      @sub_heading = CollectionConfig.ed_community_subheading(collection_configs)
      @partners = CollectionConfig.ed_community_partners(collection_configs)
      @breadcrumbs = {
        @state[:long].titleize => state_path(gs_legacy_url_encode @state[:long]),
        'Education Community' => nil
      }
      @canonical_url = state_education_community_url(params[:state])
      gon.state_abbr = @state[:short]

      render 'shared/community'
    end
  end

  def ad_setTargeting_through_gon
    @ad_definition = Advertising.new
    if show_ads?
      ad_targeting_gon_hash['compfilter'] = (1 + rand(4)).to_s # 1-4   Allows ad server to serve 1 ad/page when required by adveritiser
      ad_targeting_gon_hash['env']        = ENV_GLOBAL['advertising_env'] # alpha, dev, product, omega?
      ad_targeting_gon_hash['State']      = @state[:short].upcase # abbreviation
      ad_targeting_gon_hash['editorial']  = 'FindaSchoo'
      ad_targeting_gon_hash['template']   = "ros" # use this for page name - configured_page_name
    end
  end

  private

    def set_community_omniture_data
      if @tab == 'Community' || @show_tabs == false
        page_name = "GS:State:EducationCommunity"
        page_hier = "Home,StateHome,EducationCommunity"
      else
        page_name = "GS:State:EducationCommunity:#{@tab}"
        page_hier = "Home,StateHome,EducationCommunity,#{@tab}"
      end

      set_omniture_data(page_name, page_hier, @state[:long].titleize)
    end

  def set_state_home_omniture_data
    set_omniture_data('GS:State:Home', 'Home,StateHome')
  end
end
