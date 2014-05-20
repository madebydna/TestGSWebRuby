class LocalizedProfileController < ApplicationController
  protect_from_forgery

  include OmnitureConcerns

  before_filter :redirect_tab_urls, only: [:overview]
  before_filter :require_state, :require_school
  before_filter :redirect_to_canonical_url, only: [:overview, :quality, :details, :reviews]
  before_filter :read_config_for_page
  before_filter :init_page, :set_header_data
  before_filter :store_location, only: [:overview, :quality, :details, :reviews]
  before_filter :set_last_school_visited, only: [:overview, :quality, :details, :reviews]
  before_filter :set_seo_meta_tags

  before_filter :ad_setTargeting_through_gon
  before_filter :set_city_state
  before_filter :set_hub_params, if: :is_hub_school?
  before_filter :enable_ads
  # after_filter :set_last_modified_date

  layout 'application'

  def overview
    #Set the pagename before setting other omniture props.
    gon.omniture_pagename = 'GS:SchoolProfiles:Overview'
    set_omniture_data(gon.omniture_pagename)
    @canonical_url = school_url(@school)
  end

  def quality
    #Set the pagename before setting other omniture props.
    gon.omniture_pagename = 'GS:SchoolProfiles:Quality'
    set_omniture_data(gon.omniture_pagename)
    @canonical_url = school_url(@school)
  end

  def details
    #Set the pagename before setting other omniture props.
    gon.omniture_pagename = 'GS:SchoolProfiles:Details'
    set_omniture_data(gon.omniture_pagename)
    @canonical_url = school_url(@school)
  end

  def reviews
    #Set the pagename before setting other omniture props.
    gon.omniture_pagename = 'GS:SchoolProfiles:Reviews'
    set_omniture_data(gon.omniture_pagename)
    @canonical_url = school_reviews_url(@school)
    @canonical_url = school_url(@school)

    @school_reviews = @school.reviews_filter quantity_to_return: 10

    @review_offset = 0
    @review_limit = 10
  end

  protected

  def set_omniture_data(page_name)
    set_omniture_hier_for_new_profiles
    set_omniture_data_for_school(page_name)
    set_omniture_data_for_user_request
  end

  def init_page
    @school_reviews_all = @school.reviews.all
    @google_signed_image = GoogleSignedImages.new @school, gon
    gon.pagename = configured_page_name
    gon.review_count = @school_reviews_all.count();
    @cookiedough = SessionCacheCookie.new cookies[:SESSION_CACHE]
    @sweepstakes_enabled = PropertyConfig.sweepstakes?
    @ad_definition = Advertising.new
    set_last_modified_date
  end

  def read_config_for_page
    @page_config = PageConfig.new configured_page_name, @school
    @school.page = @page_config
  end

  def set_header_data
    @header_metadata = @school.school_metadata
    @school_reviews_global = SchoolReviews.calc_review_data @school_reviews_all
  end



  # requires that @school has already been obtained from db
  def redirect_to_canonical_url
    helper_name = 'school_'
    helper_name << "#{action_name}_" if action_name != 'overview'
    helper_name << 'path'

    canonical_path = self.send helper_name.to_sym, @school


    # Add a tailing slash to the request path, only if one doesn't already exist.
    # Requests made by rspec sometimes contain a trailing slash
    unless canonical_path == with_trailing_slash(request.path)
      redirect_to add_query_params_to_url(
        canonical_path,
        true,
        request.query_parameters
      )
    end
  end

  def set_seo_meta_tags
    set_meta_tags :title => seo_meta_tags_title,
                  :description => seo_meta_tags_description,
                  :keywords =>  seo_meta_tags_keywords
  end

  # title logic
  # schoolName+' - '+city+', '+stateNameFull+' - '+stateAbbreviation+' - School '+PageName
  def seo_meta_tags_title
    return_title_str = ''
    return_title_str << @school.name + ' - '
     if @school.state.downcase == 'dc'
       return_title_str << 'Washington, DC'
     else
       return_title_str << @school.city + ', ' + @school.state_name.capitalize + ' - ' + @school.state
     end
     return_title_str << ' - School ' + action_name

  end

  def seo_meta_tags_description
    return_description_str = ''
    state_name_local = ''
    return_description_str << @school.name
    state_name_local = @school.state_name.capitalize
    if @school.state.downcase == 'dc'
      state_name_local = 'Washington DC'
    end
    if @school.preschool?
      return_description_str << ' in ' + @school.city + ', ' + state_name_local + ' (' + @school.state + ')'
      return_description_str << ". Read parent reviews and get the scoop on the school environment, teachers,"
      return_description_str << " students, programs and services available from this preschool."
    else
      return_description_str << ' located in ' + @school.city + ', ' + state_name_local + ' - ' + @school.state
      return_description_str << '. Find ' +  @school.name + ' test scores, student-teacher ratio, parent reviews and teacher stats.'
    end
    return_description_str
  end

  def seo_meta_tags_keywords
    name = @school.name.clone
    return_keywords_str  =''
    return_keywords_str << name
    if @school.preschool?
      if name.downcase.end_with? 'pre-school'
        return_keywords_str << ', ' + name.gsub(/\ (pre-school)$/i, ' preschool').gs_capitalize_words
      elsif name.downcase.end_with? 'preschool'
        return_keywords_str << ', ' + name.gsub(/\ (preschool)$/i, ' pre-school').gs_capitalize_words
      end
    else
      return_keywords_str << ', ' + name + ' ' + @school.city
      return_keywords_str << ', ' + name + ' ' + @school.city + ' ' +  @school.state_name.capitalize
      return_keywords_str << ', ' + name + ' ' + @school.city + ' ' + @school.state
      return_keywords_str << ', ' + name + ' ' + @school.state_name.capitalize
      return_keywords_str << ', ' + name + ' ' + action_name
    end
    return_keywords_str
  end

  def set_last_modified_date
    review_date = @school_reviews_all.present? ? @school_reviews_all.first.posted : nil
    school_date = @school.modified.present? ? @school.modified.to_date : nil
    @last_modified_date = review_date ? (review_date > school_date) ? review_date : school_date : school_date
  end

  def set_footer_cities
    @cities = City.popular_cities(@state, limit: 28)
  end

  def ad_setTargeting_through_gon
    if @school.show_ads
      set_targeting = {}
      # City, compfilter, county, env, gs_rating, level, school_id, State, type, zipcode, district_id, template
      set_targeting['City'] = @school.city
      set_targeting['compfilter'] = 1 + rand(4) # 1-4   Allows ad server to serve 1 ad/page when required by adveritiser
      set_targeting['county'] = @school.county # county name?
      set_targeting['env'] = ENV_GLOBAL['advertising_env'] # alpha, dev, product, omega?
      set_targeting['gs_rating'] = @school.gs_rating
      set_targeting['level'] = @school.level_code # p,e,m,h
      set_targeting['school_id'] = @school.id
      set_targeting['State'] = @school.state # abbreviation
      set_targeting['type'] = @school.type  # private, public, charter
      set_targeting['zipcode'] = @school.zipcode
      set_targeting['district_id'] = @school.district.present? ? @school.district.FIPScounty : ""
      set_targeting['template'] = "ros" # use this for page name - configured_page_name

      gon.ad_set_targeting = set_targeting
    end
  end

  def is_hub_school?
    @school && !@school.try(:collection).nil?
  end

  def enable_ads
    @show_ads = @school.show_ads
  end
end
