class CitiesController < ApplicationController
  include CommunityParams
  include AdvertisingConcerns
  include PageAnalytics
  include CommunityConcerns

  layout 'application'
  before_filter :redirect_unless_valid_city

  def show
    gon.city = {
      schools: serialized_schools,
    }.tap do |props|

    end

    ######################Extract breadcrumbs, ad targeting, meta tags, etc from this old code.
    # @breadcrumbs = {
    #     @state[:long].titleize => state_path(params[:state]),
    #     @city.titleize => nil
    # }


      # gon.pagename = 'GS:City:Home'
      # @ad_page_name = 'City_Page'.to_sym
      #
      #
      # @show_ads = true
      # if @hub.present?
      #   @collection_id = @hub.collection_id
      #   collection_configs = hub_configs(@collection_id)
      #   @show_ads = CollectionConfig.show_ads(collection_configs)
      # end
      #
      # @top_schools = all_schools_by_rating_desc(@city_object,4)
      # @districts = District.by_number_of_schools_desc(@city_object.state,@city_object).take(5)
      # @show_ads = @show_ads && PropertyConfig.advertising_enabled?
      # gon.show_ads = show_ads?
      # ad_setTargeting_through_gon
      # gon.pagename = 'GS:City:Home'
      # data_layer_through_gon
      # @canonical_url = city_url(gs_legacy_url_encode(@state[:long]), gs_legacy_url_encode(@city))
    ####################################

    ##########New meta tag, analytics, and ad targeting code
    # set_city_meta_tags
    # set_ad_targeting_props
    # set_page_analytics_data
    # set_meta_tags(alternate: {
    #   en: url_for(params_for_rel_alternate.merge(lang: nil)),
    #   es: url_for(params_for_rel_alternate.merge(lang: :es))
    # })
  end

  def search_breadcrumbs
    @_search_breadcrumbs ||= [
      {
        text: StructuredMarkup.state_breadcrumb_text(state),
        url: state_url(state_params(state))
      },
      {
        text: StructuredMarkup.city_breadcrumb_text(state: state, city: city),
        url: city_url(city_params(state, city))
      }
    ]
  end

  # StructuredMarkup
  def prepare_json_ld
    search_breadcrumbs.each { |bc| add_json_ld_breadcrumb(bc) }
  end

  private

  def redirect_unless_valid_city
    redirect_to(state_path(States.state_path(state)), status: 301) unless city_record
  end

  def default_extras
    %w(summary_rating enrollment review_summary)
  end

  def write_meta_tags
    method_base = "#{controller_name}_#{action_name}"
    title_method = "#{method_base}_title".to_sym
    description_method = "#{method_base}_description".to_sym
    set_meta_tags title: send(title_method), description: send(description_method)
  end

  def all_schools_by_rating_desc(city, count=0)
    @all_schools_in_city_by_rating_desc ||= city.schools_by_rating_desc
    count != 0 ? @all_schools_in_city_by_rating_desc.take(count) : @all_schools_in_city_by_rating_desc
  end

  def set_city_home_metadata
    description = "Find top-rated #{@city.titleize} schools, read recent parent reviews, "+
      "and browse private and public schools by grade level in #{@city.titleize}, #{(@state[:long]).titleize} (#{(@state[:short]).upcase})."

      state_text = @state[:short].downcase == 'dc' ? '' : "#{@city.titleize} #{@state[:long].titleize} "
      additional_city_text = @state[:short].downcase == 'dc' ? ', DC' : ''


      if %w(pa nj co in).include?(@state[:short].downcase)
        title = "View The Best Schools in #{@city.titleize}, #{@state[:short].upcase} | School Ratings for Public & Private"
      else
        title = "#{@city.titleize}#{additional_city_text} Schools - #{state_text}School Ratings - Public and Private"
      end

      set_meta_tags description: description,
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
