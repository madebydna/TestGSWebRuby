class SchoolProfilesController < ApplicationController
  protect_from_forgery
  before_filter :require_school
  before_action :redirect_to_canonical_url
  before_action :add_dependencies_to_gon

  layout "application"
  PAGE_NAME = "GS:SchoolProfile:SinglePage"

  def show
    @school = school
    set_last_school_visited
    add_profile_structured_markup
    set_seo_meta_tags
    build_gon_object
    if @school.private_school?
      @private_school_profile = private_school_profile
      render 'show_private_school'
    else
      @school_profile = school_profile
    end
  end

  private

  def add_profile_structured_markup
    add_json_ld(StructuredMarkup.school_hash(school, school.reviews_with_calculations))
    add_json_ld(StructuredMarkup.breadcrumbs_hash(school))
    add_json_ld({
      "@context" => "http://schema.org",
      "@type" => "ProfilePage",
      "dateModified" => l(school_profile.last_modified_date, format: '%Y-%m-%d'),
      "description" => StructuredMarkup.description(school: school, gs_rating: school_cache_data_reader.gs_rating.to_s)
    })
  end

  def page_view_metadata
    @_page_view_metadata ||= (
      school_gs_rating = school_cache_data_reader.gs_rating.to_s
      number_of_reviews_with_comments = school.reviews.having_comments.count
      SchoolProfiles::PageViewMetadata.new(school,
                                           PAGE_NAME,
                                           school_gs_rating,
                                           number_of_reviews_with_comments)
        .hash
    )
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
        sp.student_progress = student_progress
        sp.reviews = reviews
        sp.review_questions = review_questions
        sp.students = students
        sp.nearby_schools = nearby_schools
        sp.last_modified_date = last_modified_date
        sp.neighborhood = neighborhood
        sp.equity = equity
        sp.toc = toc
        sp.breadcrumbs = breadcrumbs
        sp.teachers_staff = teachers_staff
        sp.show_high_school_data = show_high_school_data?
        sp.courses = courses
      end
    )
  end

  def private_school_profile
    @_private_school_profile ||= (
    OpenStruct.new.tap do |psp|
      psp.hero = hero
      psp.reviews = reviews
      psp.review_questions = review_questions
      psp.students = students
      psp.nearby_schools = nearby_schools
      psp.last_modified_date = last_modified_date
      psp.neighborhood = neighborhood
      psp.toc = toc # TODO - do we want something like a toc_private method? probably...
      psp.breadcrumbs = breadcrumbs
      psp.tab_config = private_school_info.tab_config
      psp.school = school
      psp.source_name = private_school_info.source_name
      psp.claimed = hero.has_osp_badge?
      psp.mailto = private_school_info.mailto
    end
    )
  end

  def show_high_school_data?
    school.level_code =~ /h/
  end

  def get_school_params
    params.permit(:schoolId, :school_id, :state)
    params[:id] = params[:schoolId] || params[:school_id]
    params[:state_abbr] = States.abbreviation(params[:state].gsub('-', ' '))
    params
  end

  def require_school
    if school.blank?
      redirect_to city_path(city_params(state_param, city_param)), status: :found
    elsif !school.active? && !school.demo_school?
      redirect_to city_path(city_params(school.state_name, school.city)), status: :found
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

  def toc
    SchoolProfiles::Toc.new(test_scores, college_readiness, student_progress, equity, students, teachers_staff, courses, school)
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

  def student_progress
    SchoolProfiles::StudentProgress.new(
        school,
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

  def courses
    SchoolProfiles::Courses.new(
      school_cache_data_reader: school_cache_data_reader
    )
  end

  def reviews
    # This needs ReviewQuestions for the topical distribution popup
    @_reviews ||= SchoolProfiles::Reviews.new(school, review_questions)
  end

  def review_questions
    @_review_questions ||= SchoolProfiles::ReviewQuestions.new(school)
  end

  def neighborhood
    SchoolProfiles::Neighborhood.new(school, school_cache_data_reader)
  end

  def nearby_schools
    SchoolProfiles::NearbySchools.new(school_cache_data_reader: school_cache_data_reader)
  end

  def breadcrumbs
    {
      StructuredMarkup.state_breadcrumb_text(school.state) => state_path(state_params(school.state)),
      StructuredMarkup.city_breadcrumb_text(state: school.state, city: school.city) => city_path(city_params(school.state, school.city)),
      t('controllers.school_profile_controller.schools') => search_city_browse_path(city_params(school.state, school.city)),
      t('controllers.school_profile_controller.school_profile') => nil
    }
  end

  def teachers_staff
    SchoolProfiles::TeachersStaff.new(school_cache_data_reader)
  end

  def private_school_info
    SchoolProfiles::PrivateSchoolInfo.new(school, school_cache_data_reader)
  end

  def build_gon_object
    add_gon_school_obj
    add_gon_links
    add_gon_ethnicity
    add_gon_subgroup
    add_gon_gender
    data_layer_through_gon
    add_gon_ad_set_targeting
  end

  def add_gon_school_obj
    if school.present?
      gon.school = {
        :id => school.id,
        :state => school.state
      }
    end
  end

  def add_gon_links
    gon.links = {
      terms_of_use: terms_of_use_path,
      school_review_guidelines: school_review_guidelines_path,
      session: api_session_path,
      school_user_digest: api_school_user_digest_path
    }
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

  def data_layer_through_gon
    data_layer_gon_hash.merge!(page_view_metadata)
  end

  def add_gon_ad_set_targeting
    if school.show_ads
      # City, compfilter, county, env, gs_rating, level, school_id, State, type, zipcode, district_id, template
      # @school.city.delete(' ').slice(0,10)
      page_view_metadata.each do |key, value|
        ad_targeting_gon_hash[key] = value
      end
    end
  end

  def set_seo_meta_tags
    meta_tags = SchoolProfileMetaTags.new(school)
    canonical_url = school_url(school)
    set_meta_tags title: meta_tags.title,
                  description: meta_tags.description,
                  keywords: meta_tags.keywords,
                  canonical: canonical_url,
                  alternate: {
                      en: remove_query_params_from_url(canonical_url, [:lang]),
                      es: add_query_params_to_url(canonical_url, true, {lang: :es})
                  }
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
    [review_date, school_date, *(school_cache_data_reader.cache_updated_dates)].compact.max
  end

  def add_dependencies_to_gon
    gon.dependencies = {
        highcharts: ActionController::Base.helpers.asset_path('highcharts.js')
    }
  end
end
