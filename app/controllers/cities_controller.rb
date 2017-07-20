class CitiesController < ApplicationController
  include ApplicationHelper
  include SeoHelper
  include SearchHelper
  include SchoolHelper
  include GoogleMapConcerns
  include CitiesMetaTagsConcerns
  include CommunityTabConcerns
  include PopularCitiesConcerns

  before_action :set_city_state
  before_action :set_hub
  before_action :add_collection_id_to_gtm_data_layer
  before_action :set_login_redirect
  before_action :set_no_index

  def show
    # write_meta_tags
    @cities = popular_cities
    @city_object = City.where(name: @city, state: @state[:short], active: 1).first

    @breadcrumbs = {
        @state[:long].titleize => state_path(params[:state]),
        @city.titleize => nil
    }

    if @hub && hub_matching_current_url[:city]
      city_hub
    else
      gon.pagename = 'GS:City:Home'
      @ad_page_name = 'City_Page'.to_sym

      if @city_object.blank? && @state.present?
        return redirect_to state_url
      end

      @show_ads = true
      if @hub.present?
        @collection_id = @hub.collection_id
        collection_configs = hub_configs(@collection_id)
        @show_ads = CollectionConfig.show_ads(collection_configs)
      end

      @city_rating = CityRating.get_rating(@state[:short], @city)
      @top_schools = all_schools_by_rating_desc(@city_object,4)
      @districts = District.by_number_of_schools_desc(@city_object.state,@city_object).take(5)
      @show_ads = @show_ads && PropertyConfig.advertising_enabled?
      gon.show_ads = show_ads?
      ad_setTargeting_through_gon
      gon.pagename = 'GS:City:Home'
      data_layer_through_gon
      #overwrites tags set by write_meta_tags above
      set_city_home_metadata
    end
  end

  def city_hub
    write_meta_tags
    @cities = popular_cities
    @hub.has_guided_search?

    @collection_id = @hub.collection_id
    collection_configs = hub_configs(@collection_id)
    @browse_links = CollectionConfig.browse_links(collection_configs)
    @collection_nickname = CollectionConfig.collection_nickname(collection_configs)
    @sponsor = CollectionConfig.sponsor(collection_configs)
    @choose_school = CollectionConfig.city_hub_choose_school(collection_configs)
    @announcement = CollectionConfig.city_hub_announcement(collection_configs)
    @articles = CollectionConfig.city_featured_articles(collection_configs)
    @partner_carousel = parse_partners CollectionConfig.city_hub_partners(collection_configs)
    @important_events = CollectionConfig.city_hub_important_events(collection_configs)
    @hero_image = "hubs/desktop/#{@collection_id}-#{@state[:short].upcase}_hero.jpg"
    @hero_image_mobile = "hubs/small/#{@collection_id}-#{@state[:short].upcase}_hero_small.jpg"
    @canonical_url = city_url(gs_legacy_url_encode(@state[:long]), gs_legacy_url_encode(@city))
    @show_ads = CollectionConfig.show_ads(collection_configs) && PropertyConfig.advertising_enabled?
    ad_setTargeting_through_gon
    gon.pagename = 'GS:City:Home'
    data_layer_through_gon
    gon.state_abbr = @state[:short]

    render 'hubs/city_hub'
  end

  def events
    write_meta_tags
    @cities = popular_cities
    if @hub.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      @collection_id = @hub.collection_id
      collection_configs = hub_configs(@collection_id)

      @collection_nickname = CollectionConfig.collection_nickname(collection_configs)
      @events = CollectionConfig.important_events(@collection_id)
      @breadcrumbs = {
        @state[:long].titleize => state_path(params[:state]),
        @city.titleize => city_path(params[:state], params[:city]) ,
        t('events', scope: 'controllers.cities_controller') =>nil
      }
      @canonical_url = city_events_url(@state[:long], @city)
      gon.pagename = 'GS:City:Events'
      data_layer_through_gon
      gon.state_abbr = @state[:short]

      render 'hubs/events'
    end
  end

  def community
    write_meta_tags
    @cities = popular_cities
    if @hub.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      @collection_id = @hub.collection_id
      collection_configs = hub_configs(@collection_id)
      @show_tabs = CollectionConfig.ed_community_show_tabs(collection_configs)
      @tab = get_community_tab_from_request_path(request.path, @show_tabs)

      set_community_gon_pagename

      @collection_nickname = CollectionConfig.collection_nickname(collection_configs)
      @important_events = CollectionConfig.city_hub_important_events(collection_configs)
      @sub_heading = CollectionConfig.ed_community_subheading(collection_configs)
      @partners = CollectionConfig.ed_community_partners(collection_configs)
      @breadcrumbs = {
        @state[:long].titleize => state_path(params[:state]),
        @city.titleize => city_path(params[:state], params[:city]),
        t('education_community', scope: 'controllers.cities_controller') => nil
      }
      @canonical_url = city_education_community_url(params[:state], params[:city])
      data_layer_through_gon
      gon.state_abbr = @state[:short]

      render 'hubs/community'
    end
  end

  def partner
    @cities = popular_cities
    if @hub.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      @collection_id = @hub.collection_id
      collection_configs = hub_configs(@collection_id)

      @collection_nickname = CollectionConfig.collection_nickname(collection_configs)
      @partner = CollectionConfig.partner(collection_configs)
      @events = CollectionConfig.city_hub_important_events(collection_configs)
      @breadcrumbs = {
        @state[:long].titleize => state_path(params[:state]),
        @city.titleize => city_path(params[:state], params[:city]),
        t('partner', scope: 'controllers.cities_controller') => nil
      }
      @canonical_url = city_education_community_partner_url(params[:state], params[:city])
      set_meta_tags keywords: partner_page_meta_keywords(@partner[:page_name], @partner[:acro_name]),
                    description: partner_page_description(@partner[:page_name]),
                    title: @partner[:page_name]
      gon.pagename = 'GS:City:Partner'
      data_layer_through_gon
      gon.state_abbr = @state[:short]

    end
  end


  def choosing_schools
    write_meta_tags
    @cities = popular_cities
    if @hub.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else

      @collection_id = @hub.collection_id
      collection_configs = hub_configs(@collection_id)

      @collection_nickname = CollectionConfig.collection_nickname(collection_configs)
      @events = CollectionConfig.city_hub_important_events(collection_configs)
      @step3_links = CollectionConfig.choosing_page_links(collection_configs)
      @step3_search_links = CollectionConfig.choosing_page_search_links(collection_configs)
      @breadcrumbs = {
        @state[:long].titleize => state_path(params[:state]),
        @city.titleize => city_path(params[:state], params[:city]),
        t('choosing_a_school', scope: 'controllers.cities_controller') => nil
      }
      @canonical_url = city_choosing_schools_url(params[:state], params[:city])
      gon.pagename = 'GS:City:ChoosingSchools'
      data_layer_through_gon
      gon.state_abbr = @state[:short]

      render 'hubs/choosing_schools'
    end
  end

  def enrollment
    write_meta_tags
    if @hub.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      @collection_id = @hub.collection_id
      collection_configs = hub_configs(@collection_id)

      @collection_nickname = CollectionConfig.collection_nickname(collection_configs)
      @events = CollectionConfig.city_hub_important_events(collection_configs)
      @tab = CollectionConfig.enrollment_tabs(@state[:short], @collection_id, params[:tab])
      @subheading = CollectionConfig.enrollment_subheading(collection_configs)
      @enrollment_module = CollectionConfig.enrollment_module(collection_configs, @tab[:key])
      @tips = CollectionConfig.enrollment_tips(collection_configs, @tab[:key])
      @key_dates = CollectionConfig.key_dates(collection_configs, @tab[:key])

      @breadcrumbs = {
        @state[:long].titleize => state_path(params[:state]),
        @city.titleize => city_path(params[:state], params[:city]),
        t('enrollment_information', scope: 'controllers.cities_controller') => nil
      }

      @canonical_url = city_enrollment_url(params[:state], params[:city])
      set_enrollment_gon_pagename
      data_layer_through_gon
      gon.state_abbr = @state[:short]

      render 'hubs/enrollment'
    end
  end

  def programs
    write_meta_tags
    @cities = popular_cities
    if @hub.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      @collection_id = @hub.collection_id
      collection_configs = hub_configs(@collection_id)

      @collection_nickname = CollectionConfig.collection_nickname(collection_configs)
      @important_events = CollectionConfig.city_hub_important_events(collection_configs)
      @heading = CollectionConfig.programs_heading(collection_configs)
      @intro = CollectionConfig.programs_intro(collection_configs)
      @sponsor = CollectionConfig.programs_sponsor(collection_configs)
      @partners = CollectionConfig.programs_partners(collection_configs)
      @articles = CollectionConfig.programs_articles(collection_configs)
      @canonical_url = city_programs_url(params[:state], params[:city])
      @breadcrumbs = {
              @state[:long].titleize => state_path(params[:state]),
              @city.titleize => city_path(params[:state], params[:city]) ,
              t('programs', scope: 'controllers.cities_controller') =>nil
            }
      gon.pagename = 'GS:City:Programs'
      data_layer_through_gon
      gon.state_abbr = @state[:short]

    end
  end

  private

  def write_meta_tags
    method_base = "#{controller_name}_#{action_name}"
    title_method = "#{method_base}_title".to_sym
    description_method = "#{method_base}_description".to_sym
    keywords_method = "#{method_base}_keywords".to_sym
    set_meta_tags title: send(title_method), description: send(description_method), keywords: send(keywords_method)
  end

  def all_schools_by_rating_desc(city, count=0)
    @all_schools_in_city_by_rating_desc ||= city.schools_by_rating_desc
    count != 0 ? @all_schools_in_city_by_rating_desc.take(count) : @all_schools_in_city_by_rating_desc
  end

  def set_city_home_metadata
    description = "Find top-rated #{@city.titleize} schools, read recent parent reviews, "+
      "and browse private and public schools by grade level in #{@city.titleize}, #{(@state[:long]).titleize} (#{(@state[:short]).upcase})."

    keywords = "#{@city.titleize} Schools, #{@city.titleize} #{@state[:short].upcase} Schools, #{@city.titleize} Public Schools, "+
      "#{@city.titleize} School Ratings, Best #{@city.titleize} Schools, #{@city.titleize} #{@state[:long].titleize} Schools, "+
      "#{@city.titleize} Private Schools"

      state_text = @state[:short].downcase == 'dc' ? '' : "#{@city.titleize} #{@state[:long].titleize} "
      additional_city_text = @state[:short].downcase == 'dc' ? ', DC' : ''


      if @state[:short] == 'pa'
        title = "View The Best Schools in #{@city.titleize}, #{@state[:short].upcase} | School Ratings for Public & Private"
      else
        title = "#{@city.titleize}#{additional_city_text} Schools - #{state_text}School Ratings - Public and Private"
      end

      set_meta_tags keywords: keywords,
        description: description,
        title: title
  end


  def set_enrollment_gon_pagename
    # preschool not tracked separately since it is the default state of the page
    if @tab[:key] == 'preschool'
      page_name = "GS:City:Enrollment"
    else
      page_name = "GS:City:Enrollment:#{@tab[:key].titleize}"
    end
    gon.pagename = page_name
  end

  def set_community_gon_pagename
    if @tab == 'Community' || @show_tabs == false
      page_name = "GS:City:EducationCommunity"
    else
      page_name = "GS:City:EducationCommunity:#{@tab}"
    end
    gon.pagename = page_name
  end

  def parse_partners(partners)
    partners.try(:[], :partnerLogos).try(:map) { |partner| partner[:anchoredLink].prepend(city_path(params[:state], params[:city]))  }
    partners
  end

  def page_view_metadata
    @page_view_metadata ||= (
      page_view_metadata = {}
      page_view_metadata['page_name']   = gon.pagename || 'GS:City:Home'
      page_view_metadata['template']    = 'ros' # use this for page name - configured_page_name
      page_view_metadata['City']        = @city.gs_capitalize_words
      page_view_metadata['State']       = @state[:short].upcase # abbreviation
      page_view_metadata['county']      = county_object.try(:name) if county_object

      page_view_metadata

    )
  end

  def ad_setTargeting_through_gon
    @ad_definition = Advertising.new
    if show_ads?
      page_view_metadata.each do |key, value|
        ad_targeting_gon_hash[key] = value
      end
    end
  end

  def data_layer_through_gon
    data_layer_gon_hash.merge!(page_view_metadata)
  end

  def county_object
    if @city_object && @city_object.respond_to?(:county)
      @city_object.county
    end
  end
end
