class SchoolProfileController < SchoolController
  protect_from_forgery

  include OmnitureConcerns
  include AdvertisingHelper

  before_action :redirect_tab_urls, only: [:overview]
  before_action :require_state, :require_school
  before_action :redirect_to_canonical_url, only: [:overview, :quality, :details, :reviews]
  before_action :read_config_for_page
  before_action :init_page, :set_header_data
  before_action :store_location, only: [:overview, :quality, :details, :reviews]
  before_action :set_last_school_visited, only: [:overview, :quality, :details, :reviews]
  before_action :set_seo_meta_tags

  before_action :ad_setTargeting_through_gon
  before_action :set_city_state
  before_action :set_hub_params, if: :is_hub_school?
  before_action :enable_ads
  before_action :set_breadcrumbs
  # after_filter :set_last_modified_date

  layout 'application'

  protected

  def set_omniture_data(page_name)
    set_omniture_hier_for_new_profiles
    set_omniture_data_for_school(page_name)
    set_omniture_data_for_user_request
  end

  def init_page
    @school_reviews_all = @school.reviews.load
    create_sized_maps(gon)
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

  def ad_setTargeting_through_gon
    if @school.show_ads
      set_targeting = {}
      # City, compfilter, county, env, gs_rating, level, school_id, State, type, zipcode, district_id, template
      # @school.city.delete(' ').slice(0,10)
      set_targeting['City'] = format_ad_setTargeting(@school.city)
      set_targeting['compfilter'] = format_ad_setTargeting((1 + rand(4)).to_s) # 1-4   Allows ad server to serve 1 ad/page when required by adveritiser
      set_targeting['county'] = format_ad_setTargeting(@school.county) # county name?
      set_targeting['env'] = format_ad_setTargeting(ENV_GLOBAL['advertising_env']) # alpha, dev, product, omega?
      set_targeting['gs_rating'] = format_ad_setTargeting(@school.gs_rating)
      set_targeting['level'] = format_ad_setTargeting(@school.level_code) # p,e,m,h
      set_targeting['school_id'] = format_ad_setTargeting(@school.id.to_s)
      set_targeting['State'] = format_ad_setTargeting(@school.state) # abbreviation
      set_targeting['type'] = format_ad_setTargeting(@school.type)  # private, public, charter
      set_targeting['zipcode'] = format_ad_setTargeting(@school.zipcode)
      set_targeting['district_id'] = format_ad_setTargeting(@school.district.present? ? @school.district.FIPScounty : "")
      set_targeting['template'] = format_ad_setTargeting("ros") # use this for page name - configured_page_name

      gon.ad_set_targeting = set_targeting
    end
  end

  def is_hub_school?
    @school && !@school.try(:collection).nil?
  end

  def enable_ads
    @show_ads = @school.show_ads
  end

  def set_breadcrumbs
    school = SchoolProfileDecorator.decorate(@school)
    @breadcrumbs = {
      'Home' => home_url,
      school.state_breadcrumb_text => state_url(state_params(school.state)),
      school.city_breadcrumb_text => city_url(city_params(school.state, school.city))
    }
  end

  # requires that @school has already been obtained from db
  def canonical_path
    helper_name = 'school_'
    helper_name << "#{action_name}_" if action_name != 'overview'
    helper_name << 'path'
    canonical_path = self.send helper_name.to_sym, @school
  end
  
end
