class SchoolProfileController < SchoolController
  protect_from_forgery

  # TODO: Refactor these actions
  before_action :redirect_tab_urls, only: [:overview]
  before_action :require_state, :require_school
  before_action :redirect_to_canonical_url, only: [:overview, :quality, :details, :reviews]
  before_action :read_config_for_page, only: [:overview, :quality, :details, :reviews]
  before_action :init_page, :set_header_data, only: [:overview, :quality, :details, :reviews]
  before_action :store_location, only: [:overview, :quality, :details, :reviews]
  before_action :set_last_school_visited, only: [:overview, :quality, :details, :reviews]
  before_action :set_seo_meta_tags, only: [:overview, :quality, :details, :reviews]

  before_action :ad_setTargeting_through_gon, only: [:overview, :quality, :details, :reviews]
  before_action :set_city_state, only: [:overview, :quality, :details, :reviews]
  before_action :facebook_comments_permalink, only: [:overview, :quality, :details, :reviews]
  before_action :set_hub, only: [:overview, :quality, :details, :reviews]
  before_action :enable_ads, only: [:overview, :quality, :details, :reviews]
  before_action :set_breadcrumbs, only: [:overview, :quality, :details, :reviews]
  # after_filter :set_last_modified_date

  layout 'application'

  protected

  def set_omniture_data(page_name)
    set_omniture_hier_for_new_profiles
    set_omniture_data_for_school(page_name)
    set_omniture_data_for_user_request
  end

  def init_page
    set_noindex_meta_tags if @school.demo_school?
    @school_reviews = SchoolReviews.new(@school)
    create_sized_maps(gon)
    gon.pagename = configured_page_name
    gon.review_count = @school_reviews.count
    @cookiedough = SessionCacheCookie.new cookies[:SESSION_CACHE]
    @sweepstakes_enabled = PropertyConfig.sweepstakes?
    @facebook_comments_prop = PropertyConfig.get_property('facebook_comments')
    @ad_definition = Advertising.new
    @ad_page_name = ad_page_name
    set_last_modified_date
  end

  def read_config_for_page
    @page_config = PageConfig.new configured_page_name, @school
    @school.page = @page_config
  end

  def set_header_data
    @header_metadata = @school.school_metadata
    @school_reviews_global = SchoolReviews.calc_review_data @school_reviews
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
      ), status: :moved_permanently
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
    review_date = @school.reviews.present? ? @school.reviews.first.created : nil
    school_date = @school.modified.present? ? @school.modified.to_date : nil
    @last_modified_date = review_date ? (review_date > school_date) ? review_date : school_date : school_date
  end

  def ad_setTargeting_through_gon
    if @school.show_ads
      # City, compfilter, county, env, gs_rating, level, school_id, State, type, zipcode, district_id, template
      # @school.city.delete(' ').slice(0,10)
      ad_targeting_gon_hash['City']        = @school.city
      ad_targeting_gon_hash['county']      = @school.county # county name?
      ad_targeting_gon_hash['gs_rating']   = @school.gs_rating
      ad_targeting_gon_hash['level']       = @school.level_code # p,e,m,h
      ad_targeting_gon_hash['school_id']   = @school.id.to_s
      ad_targeting_gon_hash['State']       = @school.state # abbreviation
      ad_targeting_gon_hash['type']        = @school.type  # private, public, charter
      ad_targeting_gon_hash['zipcode']     = @school.zipcode
      ad_targeting_gon_hash['district_id'] = @school.district.present? ? @school.district.FIPScounty : ""
      ad_targeting_gon_hash['template']    = "SchoolProf"
    end
  end

  def enable_ads
    @show_ads = @school.show_ads && PropertyConfig.advertising_enabled?
  end

  def set_breadcrumbs
    school = SchoolProfileDecorator.decorate(@school)
    @breadcrumbs = {
      school.state_breadcrumb_text => state_url(state_params(school.state)),
      school.city_breadcrumb_text => city_url(city_params(school.state, school.city)),
      'School Profile' => nil
    }
  end

  # requires that @school has already been obtained from db
  def canonical_path
    helper_name = 'school_'
    helper_name << "#{action_name}_" if action_name != 'overview'
    helper_name << 'path'
    canonical_path = self.send helper_name.to_sym, @school
  end

  def ad_page_name
    ('School_' + @page_config.name).to_sym
  end

  def facebook_comments_permalink
    uri = URI(request.original_url)
    host = uri.host
    host = "www.greatschools.org" if uri.host == "pk.greatschools.org"
    port = (uri.port != 80 && uri.port.present?) ? ':'+uri.port.to_s : ''
    domain = "http://" + host + port + "/"

    @facebook_comments_permalink = domain+ @state[:long].downcase.gsub(' ', '-') + "/city-name/"+ @school.id.to_s +
        "-school-name/"+@page_config.name.downcase
  end

  def set_noindex_meta_tags
    set_meta_tags(robots: 'noindex, nofollow, noarchive')
  end

end
