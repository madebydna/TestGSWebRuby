class SchoolProfileController < SchoolController
  protect_from_forgery

  extend UrlHelper

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
  before_action :data_layer_through_gon, only: [:overview, :quality, :details, :reviews]
  before_action :set_city_state, only: [:overview, :quality, :details, :reviews]
  before_action :set_hub, only: [:overview, :quality, :details, :reviews]
  before_action :add_collection_id_to_gtm_data_layer, only: [:overview, :quality, :details, :reviews]
  before_action :enable_ads, only: [:overview, :quality, :details, :reviews]
  before_action :set_breadcrumbs, only: [:overview, :quality, :details, :reviews]
  before_action :set_state_school_id_gon_var
  # after_filter :set_last_modified_date

  layout 'application'

  MAX_NUMBER_OF_REVIEWS_ON_OVERVIEW = 4

  protected

  def set_omniture_data(page_name)
    set_omniture_hier_for_new_profiles
    set_omniture_data_for_school(page_name)
    set_omniture_data_for_user_request
  end

  def init_page
    @school_user = school_user if logged_in?
    set_noindex_meta_tags if @school.demo_school?
    @school_reviews = SchoolProfileReviewsDecorator.decorate(@school.reviews_with_calculations, view_context)
    @school_reviews.promote_review!(params[:review_id].to_i) if params[:review_id].present?
    @static_google_maps = static_google_maps
    gon.pagename = configured_page_name
    gon.review_count = @school_reviews.number_of_reviews_with_comments
    @cookiedough = SessionCacheCookie.new cookies[:SESSION_CACHE]
    @sweepstakes_enabled = PropertyConfig.sweepstakes?
    @ad_definition = Advertising.new
    @ad_page_name = ad_page_name
    @max_number_of_reviews_on_overview = MAX_NUMBER_OF_REVIEWS_ON_OVERVIEW
    set_last_modified_date
  end

  def read_config_for_page
    @page_config = PageConfig.new configured_page_name, @school
    @school.page = @page_config
  end

  def set_header_data
    @header_metadata = @school.school_metadata
  end



  # requires that @school has already been obtained from db
  def redirect_to_canonical_url
    helper_name = 'school_'
    helper_name << "#{action_name}_" if action_name != 'overview'
    helper_name << 'path'

    #  this prevents an endless redirect loop for the profile pages
    canonical_path = remove_query_params_from_url( self.send(helper_name.to_sym, @school), [:lang] )


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

  def page_view_metadata
    @page_view_metadata ||= (
    page_view_metadata = {}

    page_name_base = 'GS:'+ @ad_page_name.to_s

    page_view_metadata['page_name']   = page_name_base.sub! '_','Profile:'
    page_view_metadata['City']        = @school.city
    page_view_metadata['county']      = @school.county # county name?
    page_view_metadata['gs_rating']   = @school.gs_rating
    page_view_metadata['level']       = @school.level_code # p,e,m,h
    page_view_metadata['school_id']   = @school.id.to_s
    page_view_metadata['State']       = @school.state # abbreviation
    page_view_metadata['type']        = @school.type  # private, public, charter
    page_view_metadata['zipcode']     = @school.zipcode
    page_view_metadata['district_id'] = @school.district.present? ? @school.district.FIPScounty : ""
    page_view_metadata['template']    = "SchoolProf"
    page_view_metadata['collection_ids']  = @school.collection_ids

    page_view_metadata

    )
  end

  def ad_setTargeting_through_gon
    if @school.show_ads
      # City, compfilter, county, env, gs_rating, level, school_id, State, type, zipcode, district_id, template
      # @school.city.delete(' ').slice(0,10)
      page_view_metadata.each do |key, value|
        ad_targeting_gon_hash[key] = value
      end
    end
  end

  def data_layer_through_gon
    data_layer_gon_hash.merge!(page_view_metadata)
  end

  def enable_ads
    @show_ads = @school.show_ads && PropertyConfig.advertising_enabled?
  end

  def set_breadcrumbs
    school = SchoolProfileDecorator.decorate(@school)
    @breadcrumbs = {
      school.state_breadcrumb_text => state_url(state_params(school.state)),
      school.city_breadcrumb_text => city_url(city_params(school.state, school.city)),
      t('controllers.school_profile_controller.schools') => search_city_browse_url(city_params(school.state, school.city)),
      t('controllers.school_profile_controller.school_profile') => nil
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

  def set_noindex_meta_tags
    set_meta_tags(robots: 'noindex, nofollow, noarchive')
  end

  def school_user
    member =  SchoolUser.find_by_school_and_user(@school, current_user)
    unless member
      member = SchoolUser.new
      member.school = @school
      member.user = current_user
    end
    member
  end

  def set_state_school_id_gon_var
    gon.state = @school.state
    gon.school_id = @school.id
  end

  def static_google_maps
    @_static_google_maps ||= begin
      sizes = {
          'sm'     => [280, 150],
          'md'     => [400, 150],
          'lg'     => [500, 150],
          'header' => [120, 120],
      }

      google_apis_path = GoogleSignedImages::STATIC_MAP_URL
      address = GoogleSignedImages.google_formatted_street_address(@school)
      school_rating = @school.gs_rating
      map_pin_url = view_context.image_url("icons/google_map_pins/map_icon_#{school_rating}.png")

      sizes.inject({}) do |sized_maps, element|
        label = element[0]
        size = element[1]
        sized_maps[label] = GoogleSignedImages.sign_url(
          "#{google_apis_path}?size=#{size[0]}x#{size[1]}&center=#{address}&markers=#{address}&sensor=false&markers=icons:#{map_pin_url}"
        )
        sized_maps
      end
    end
  end
end
