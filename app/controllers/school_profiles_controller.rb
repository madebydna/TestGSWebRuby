class SchoolProfilesController < ApplicationController
  protect_from_forgery
  before_filter :require_school
  before_action :redirect_to_canonical_url
  before_action :add_dependencies_to_gon

  layout "application"

  def show
    @school = school
    add_profile_structured_markup
    @canonical_url = school_url(@school)
    set_seo_meta_tags
    set_hreflang
    @breadcrumbs = breadcrumbs
    @school_profile = school_profile
    @school_profile_decorator = SchoolProfileDecorator.decorate(@school)
    school_gon_obj(@school)
    add_gon_links
    add_gon_ethnicity
    add_gon_subgroup
    add_gon_gender
    @static_google_maps = static_google_maps
  end

  private

  def add_profile_structured_markup
    add_json_ld(StructuredMarkup.school_hash(school, school.reviews_with_calculations))
  end

  def school
    return @_school if defined?(@_school)
    @_school = School.find_by_state_and_id(get_school_params[:state_abbr], get_school_params[:id])
  end

  def school_profile
    @_school_profile ||= (
      OpenStruct.new.tap do |sp|
        sp.hero = hero
        sp.test_scores = test_scores
        sp.college_readiness = college_readiness
        sp.reviews = reviews
        sp.review_questions = review_questions
        sp.students = students
        sp.nearby_schools = nearby_schools
        sp.last_modified_date = last_modified_date
        sp.equity = equity
      end
    )
  end

  def get_school_params
    params.permit(:schoolId, :school_id, :state)
    params[:id] = params[:schoolId] || params[:school_id]
    params[:state_abbr] = States.abbreviation(params[:state])
    params
  end

  def require_school
    if school.blank?
      render "error/school_not_found", layout: "error", status: 404
    elsif !school.active?
      redirect_to city_path(city_params(school.state_name, school.city)), status: :moved_permanently
    end
  end

  def school_cache_data_reader
    @_school_cache_data_reader ||=
      SchoolProfiles::SchoolCacheDataReader.new(school)
  end

  def hero
    SchoolProfiles::Hero.new(
      school,
      school_cache_data_reader: school_cache_data_reader
    )
  end

  def test_scores
    SchoolProfiles::TestScores.new(
      school,
      school_cache_data_reader: school_cache_data_reader
    )
  end

  def college_readiness
    SchoolProfiles::CollegeReadiness.new(
      school_cache_data_reader: school_cache_data_reader
    )
  end

  def students
    SchoolProfiles::Students.new(
      school_cache_data_reader: school_cache_data_reader
    )
  end

  def equity
    SchoolProfiles::Equity.new(
      school_cache_data_reader: school_cache_data_reader
    )
  end

  def reviews
    @_reviews ||= SchoolProfiles::Reviews.new(school)
  end

  def review_questions
    SchoolProfiles::ReviewQuestions.new(school)
  end

  def nearby_schools
    SchoolProfiles::NearbySchools.new(school_cache_data_reader: school_cache_data_reader)
  end

  def breadcrumbs
    school = SchoolProfileDecorator.decorate(@school)
    {
      school.state_breadcrumb_text => state_url(state_params(school.state)),
      school.city_breadcrumb_text => city_url(city_params(school.state, school.city)),
      t('controllers.school_profile_controller.schools') => search_city_browse_url(city_params(school.state, school.city)),
      t('controllers.school_profile_controller.school_profile') => nil
    }
  end

  def school_gon_obj(school)
    if school.present?
      gon.school = {
          :id => school.id,
          :state => school.state
      }
    end
  end

  def add_gon_ethnicity
    gon.ethnicity = students.ethnicity_data
  end

  def add_gon_subgroup
    gon.subgroup = students.subgroups_data
  end

  def add_gon_gender
    gon.gender = students.gender_data
  end

  def add_gon_links
    gon.links = {
        terms_of_use: terms_of_use_path,
        school_review_guidelines: school_review_guidelines_path,
        session: api_session_path,
        school_user_digest: api_school_user_digest_path
    }
  end

  def set_seo_meta_tags
    set_meta_tags :title => seo_meta_tags_title,
                  :description => seo_meta_tags_description,
                  :keywords =>  seo_meta_tags_keywords
  end

  def seo_meta_tags_title
    return_title_str = ''
    return_title_str << @school.name + ' - '
    if @school.state.downcase == 'dc'
      return_title_str << 'Washington, DC'
    else
      return_title_str << @school.city + ', ' + @school.state_name.capitalize + ' - ' + @school.state
    end
    return_title_str << ' - School overview'
  end

  def seo_meta_tags_description
    return_description_str = ''
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
      return_keywords_str << ', ' + name + ' overview'
    end
    return_keywords_str
  end

  def set_hreflang
    @hreflang = {}
    @hreflang[:en] = remove_query_params_from_url(school_url(@school), [:lang])
    @hreflang[:es] = add_query_params_to_url(school_url(@school), true, {lang: :es})
    @hreflang
  end

  def redirect_to_canonical_url
    # this prevents an endless redirect loop for the profile pages
    # because of ApplicationController::url_options
    canonical_path = remove_query_params_from_url( school_path(school), [:lang] )

    # Add a trailing slash to the request path, only if one doesn't already exist.
    unless canonical_path == with_trailing_slash(request.path)
      redirect_to add_query_params_to_url(
                      canonical_path,
                      true,
                      request.query_parameters
                  ), status: :moved_permanently
    end
  end

  def last_modified_date
    reviews_list = reviews.reviews
    review_date = reviews_list.present? ? reviews_list.first.created : nil
    school_date = school.modified.present? ? school.modified.to_date : nil
    [review_date, school_date].compact.max
  end

  def static_google_maps
    @_static_google_maps ||= begin
      sizes = {
         # 'xs'     => [319, 150],
          'sm'     => [767, 450],
          'md'     => [991, 450],
          'lg' => [1264, 450]
      }

      google_apis_path = GoogleSignedImages::STATIC_MAP_URL
      address = GoogleSignedImages.google_formatted_street_address(@school)
      school_rating = nil #@school.gs_rating
      #school_rating = school_cache_data_reader.gs_rating
      if school_rating && (1..10).cover?(school_rating.to_i)
        map_pin_url = view_context.image_url("icons/google_map_pins/map_icon_#{school_rating}.png")
        icon_param = "icon:#{map_pin_url}|"
      else
        icon_param = ''
      end

      sizes.inject({}) do |sized_maps, (label, size)|
        sized_maps[label] = GoogleSignedImages.sign_url(
            "#{google_apis_path}?size=#{size[0]}x#{size[1]}&center=#{address}&markers=#{icon_param}#{address}&sensor=false"
        )
        sized = sized_maps
        sized
      end
      # sizes.each_with_object({}) do |sized_maps, (label, size)|
      #   sized_maps[label] = GoogleSignedImages.sign_url(
      #       "#{google_apis_path}?size=#{size[0]}x#{size[1]}&center=#{address}&markers=#{icon_param}#{address}&sensor=false"
      #   )
      #   sized_maps
      # end
    end
  end

  def add_dependencies_to_gon
    gon.dependencies ||= {}
    gon.dependencies[:highcharts] = ActionController::Base.helpers.asset_path('highcharts.js')
  end
end
