class CitiesController < ApplicationController
  include SeoHelper
  include MetaTagsHelper
  include AdvertisingHelper
  include ApplicationHelper
  include GuidedSearchConcerns
  include GoogleMapConcerns

  before_action :set_city_state
  before_action :set_hub
  before_action :set_login_redirect
  before_action :set_footer_cities
  before_action :write_meta_tags, except: [:partner, :guided_search]

  def show
    return city_home if params[:prototype]

    if @hub.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else

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
      @show_ads = CollectionConfig.show_ads(collection_configs)
      ad_setTargeting_through_gon
      set_omniture_data('GS:City:Home', 'Home,CityHome', @city.titleize)
      gon.state_abbr = @state[:short]

    end
  end

  def city_home
    gon.pagename = 'GS:City:Home'
    @city_object = City.where(name: @city).first
    @top_schools = all_schools_by_rating_desc(@city_object,4)
    prepare_map
    @districts = District.by_number_of_schools_desc(@city_object.state,@city_object).take(5)
    @show_ads = true
    gon.show_ads = @show_ads
    ad_setTargeting_through_gon
    set_omniture_data('GS:City:Home', 'Home,CityHome')

    description = "Find top-rated #{@city.titleize} schools, read recent parent reviews, "+
      "and browse private and public schools by grade level in #{@city.titleize}, #{(@state[:long]).titleize} (#{(@state[:short]).upcase})."

    keywords = "#{@city.titleize} Schools, #{@city.titleize} #{@state[:short].upcase} Schools, #{@city.titleize} Public Schools, "+
      "#{@city.titleize} School Ratings, Best #{@city.titleize} Schools, #{@city.titleize} #{@state[:long].titleize} Schools, "+
      "#{@city.titleize} Private Schools"

    state_text = @state[:short].downcase == 'dc' ? '' : "#{@city.titleize} #{@state[:long].titleize} "

    title = "#{@city.titleize} Schools - #{state_text}School Ratings - Public and Private"

    set_meta_tags keywords: keywords,
                  description: description,
                  title: title

    render 'city_home'
  end

  def all_schools_by_rating_desc(city, count=0)
    @all_schools_in_city_by_rating_desc ||= city.schools_by_rating_desc
    count != 0 ? @all_schools_in_city_by_rating_desc.take(count) : @all_schools_in_city_by_rating_desc
  end


  def prepare_map
    all_schools = all_schools_by_rating_desc(@city_object)
    if all_schools.present?
      top_schools_for_map_pins = all_schools.take(10)
      mapping_points_through_gon_from_db(top_schools_for_map_pins,on_page: true,show_bubble: true )

      if all_schools.size > 10
        all_other_schools_for_map = all_schools[11..-1]
        mapping_points_through_gon_from_db(all_other_schools_for_map,on_page: false)
      end
    end
    assign_sprite_files_though_gon
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
        @city.titleize => city_path(params[:state], params[:city]) ,
        'Events' =>nil
      }
      @canonical_url = city_events_url(@state[:long], @city)
      set_omniture_data('GS:City:Events', 'Home,CityHome,Events', @city.titleize)
      gon.state_abbr = @state[:short]

      render 'shared/events'
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
      @important_events = CollectionConfig.city_hub_important_events(collection_configs)
      @sub_heading = CollectionConfig.ed_community_subheading(collection_configs)
      @partners = CollectionConfig.ed_community_partners(collection_configs)
      @breadcrumbs = {
        @city.titleize => city_path(params[:state], params[:city]),
        'Education Community' => nil
      }
      @canonical_url = city_education_community_url(params[:state], params[:city])
      gon.state_abbr = @state[:short]

      render 'shared/community'
    end
  end

  def partner
    if @hub.nil?
      render 'error/page_not_found', layout: 'error', status: 404
    else
      @collection_id = @hub.collection_id
      collection_configs = hub_configs(@collection_id)

      @collection_nickname = CollectionConfig.collection_nickname(collection_configs)
      @partner = CollectionConfig.partner(collection_configs)
      @events = CollectionConfig.city_hub_important_events(collection_configs)
      @breadcrumbs = {
        @city.titleize => city_path(params[:state], params[:city]),
        'Partner' => nil
      }
      @canonical_url = city_education_community_partner_url(params[:state], params[:city])
      set_meta_tags keywords: partner_page_meta_keywords(@partner[:page_name], @partner[:acro_name]),
                    description: partner_page_description(@partner[:page_name]),
                    title: @partner[:page_name]
      set_omniture_data('GS:City:Partner', 'Home,CityHome,Partner', @city.titleize)
      gon.state_abbr = @state[:short]

    end
  end


  def choosing_schools
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
        @city.titleize => city_path(params[:state], params[:city]),
        'Choosing a School' => nil
      }
      @canonical_url = city_choosing_schools_url(params[:state], params[:city])
      set_omniture_data('GS:City:ChoosingSchools', 'Home,CityHome,ChoosingSchools', @city.titleize)
      gon.state_abbr = @state[:short]

      render 'shared/choosing_schools'
    end
  end

  def enrollment
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
        @city.titleize => city_path(params[:state], params[:city]),
        'Enrollment Information' => nil
      }

      @canonical_url = city_enrollment_url(params[:state], params[:city])
      set_enrollment_omniture_data
      gon.state_abbr = @state[:short]

      render 'shared/enrollment'
    end
  end

  def programs
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
              @city.titleize => city_path(params[:state], params[:city]) ,
              'After school and summer programs' =>nil
            }
      set_omniture_data('GS:City:Programs', 'Home,CityHome,Programs', @city.titleize)
      gon.state_abbr = @state[:short]

    end
  end

  def guided_search
    render_guided_search
  end

  private


    def set_enrollment_omniture_data
      if @tab == 'Preschools'
        page_name = "GS:City:Enrollment"
        page_hier = "Home,CityHome,Enrollment"
      else
        page_name = "GS:City:Enrollment:#{@tab[:key].titleize}"
        page_hier = "Home,CityHome,Enrollment,#{@tab[:key].titleize}"
      end

      set_omniture_data(page_name, page_hier, @city.titleize)
    end

    def set_community_omniture_data
      if @tab == 'Community' || @show_tabs == false
        page_name = "GS:City:EducationCommunity"
        page_hier = "Home,CityHome,EducationCommunity"
      else
        page_name = "GS:City:EducationCommunity:#{@tab}"
        page_hier = "Home,CityHome,EducationCommunity,#{@tab}"
      end

      set_omniture_data(page_name, page_hier, @city.titleize)
    end

    def parse_partners(partners)
      partners.try(:[], :partnerLogos).try(:map) { |partner| partner[:anchoredLink].prepend(city_path(params[:state], params[:city]))  }
      partners
    end


  def ad_setTargeting_through_gon
    @ad_definition = Advertising.new
    if @show_ads
      set_targeting = gon.ad_set_targeting || {}
      set_targeting['City'] = format_ad_setTargeting(@city.gs_capitalize_words)
      set_targeting['compfilter'] = format_ad_setTargeting((1 + rand(4)).to_s) # 1-4   Allows ad server to serve 1 ad/page when required by adveritiser
      set_targeting['env'] = format_ad_setTargeting(ENV_GLOBAL['advertising_env']) # alpha, dev, product, omega?
      set_targeting['State'] = format_ad_setTargeting(@state[:short].upcase) # abbreviation
      set_targeting['template'] = format_ad_setTargeting("ros") # use this for page name - configured_page_name

      gon.ad_set_targeting = set_targeting
    end
  end
end
