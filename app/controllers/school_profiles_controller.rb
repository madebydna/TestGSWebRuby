class SchoolProfilesController < ApplicationController
  protect_from_forgery
  before_filter :require_school
  before_action :redirect_to_canonical_url
  before_action :add_dependencies_to_gon

  layout "application"
  PAGE_NAME = "GS:SchoolProfile:SinglePage"

  set_additional_js_translations(
    {
      osp_school_info: [:school_profiles, :osp_school_info],
      school_profile_tour: [:school_profiles, :school_profile_tour],
      calendar: [:lib, :calendar]
    }
  )

  def show
    @school = school
    set_last_school_visited
    add_profile_structured_markup
    set_seo_meta_tags
    build_gon_object
    if show_private_school_template?
      @private_school_profile = private_school_profile
      render 'show_private_school'
    else
      @school_profile = school_profile
    end
    cache_time = ENV_GLOBAL['school_profile_cache_time']
    expires_in(cache_time.to_i, public: true, must_revalidate: true) if cache_time.present?
  end

  def self.show_more(module_name)
    more = I18n.t(:more, scope: 'controllers.school_profile_controller')
    category = 'Profile'
    action = 'Show More'
    label = "Parent Tips :: #{module_name}"
    "<a class=\"js-gaClick js-moreRevealLink more-reveal-link\" href=\"javascript:void(0)\" " \
        "data-ga-click-category=\"#{category}\" data-ga-click-action=\"#{action}\" data-ga-click-label=\"#{label}\">" \
        "... #{more}</a> <span class=\"js-moreReveal more-reveal\">"
  end

  def self.show_more_end
    '</span>'
  end

  private

  def add_profile_structured_markup
    add_json_ld(StructuredMarkup.school_hash(school, school_cache_data_reader.gs_rating.to_s, school.reviews_with_calculations, reviews_on_demand?))
    add_json_ld(StructuredMarkup.breadcrumbs_hash(school))
    add_json_ld({
      "@context" => "http://schema.org",
      "@type" => "ProfilePage",
      "description" => StructuredMarkup.description(school: school, gs_rating: school_cache_data_reader.gs_rating.to_s)
    })
  end

  def page_view_metadata
    @_page_view_metadata ||= begin
      school_gs_rating = school_cache_data_reader.gs_rating.to_s
      number_of_reviews_with_comments = school.reviews.having_comments.count
      csa_badge = school_cache_data_reader.csa_badge?
      dl = distance_learning.distance_learning_district?
      SchoolProfiles::PageViewMetadata.new(school,
                                           PAGE_NAME,
                                           school_gs_rating,
                                           number_of_reviews_with_comments,
                                           csa_badge,
                                           dl)
          .hash
    end
  end

  def school
    return @_school if defined?(@_school)
    @_school = School.find_by_state_and_id(get_school_params[:state_abbr], get_school_params[:id])
  end

  def school_profile
    @_school_profile ||= (
      OpenStruct.new.tap do |sp|
        sp.hero = hero
        sp.summary_rating = summary_rating
        sp.summary_narration = summary_narration
        sp.test_scores = test_scores
        sp.college_readiness = college_readiness
        sp.college_success = college_success
        sp.student_progress = student_progress
        sp.reviews = reviews
        sp.review_questions = review_questions
        sp.students = students
        sp.nearby_schools = nearby_schools
        sp.neighborhood = neighborhood
        sp.equity = equity
        sp.equity_overview = equity_overview
        sp.toc = toc
        sp.breadcrumbs = breadcrumbs
        sp.teachers_staff = teachers_staff
        sp.show_high_school_data = show_high_school_data?
        sp.osp_school_info = osp_school_info
        sp.claimed = hero.school_claimed?
        sp.stem_courses = stem_courses
        sp.academic_progress = academic_progress
        sp.reviews_on_demand = reviews_on_demand?
        sp.distance_learning = distance_learning.data_values
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
      psp.neighborhood = neighborhood
      psp.toc = toc # TODO - do we want something like a toc_private method? probably...
      psp.breadcrumbs = breadcrumbs
      psp.osp_school_info = osp_school_info
      psp.school = school
      psp.claimed = hero.school_claimed?
      psp.reviews_on_demand = reviews_on_demand?
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
    elsif school.demo_school?
      @disable_google_analytics = true
    elsif !school.active?
      redirect_to city_path(city_params(school.state_name, school.city)), status: :found
    end

  end

  def school_cache_data_reader
    @_school_cache_data_reader ||=
      SchoolProfiles::SchoolCacheDataReader.new(school)
  end

  def district_cache_data_reader
    @_district_cache_data_reader ||=begin
      return nil unless school.district.present?

      DistrictCacheDataReader.new(school.district, district_cache_keys: Array.wrap('crpe'))
    end
  end

  def distance_learning
    @_distance_learning ||= SchoolProfiles::DistanceLearning.new(school, district_cache_data_reader: district_cache_data_reader)
  end

  def hero
    SchoolProfiles::Hero.new(
      school,
      school_cache_data_reader: school_cache_data_reader
    )
  end

  def summary_rating
    @_summary_rating ||= SchoolProfiles::SummaryRating.new(
      test_scores, college_readiness, student_progress, academic_progress, equity_overview, stem_courses,
      school,
      school_cache_data_reader: school_cache_data_reader
    )
  end

  def summary_narration
    @_summary_narration ||= SchoolProfiles::SummaryNarration.new(
        summary_rating,
        school,
        school_cache_data_reader: school_cache_data_reader
    )
  end

  def toc
    SchoolProfiles::Toc.new(test_scores: test_scores, college_readiness: college_readiness,
                            college_success: college_success, student_progress: student_progress, equity: equity,
                            equity_overview: equity_overview, students: students,
                            teachers_staff: teachers_staff, stem_courses: stem_courses,
                            academic_progress: academic_progress, school: school)
  end

  def test_scores
    @_test_scores ||= SchoolProfiles::TestScores.new(
      school,
      school_cache_data_reader: school_cache_data_reader
    )
  end

  def college_readiness
    @_college_readiness ||= SchoolProfiles::CollegeReadiness.new(
      school_cache_data_reader: school_cache_data_reader
    )
  end

  def college_success
    @_college_success ||= SchoolProfiles::CollegeSuccess.new(
      school_cache_data_reader: school_cache_data_reader
    )
  end

  def student_progress
    @_student_progress ||= SchoolProfiles::StudentProgress.new(
        school,
        school_cache_data_reader: school_cache_data_reader
    )
  end

  def students
    @_student ||= SchoolProfiles::Students.new(
      school_cache_data_reader: school_cache_data_reader
    )
  end

  def equity
    @_equity ||= SchoolProfiles::Equity.new(
        school_cache_data_reader: school_cache_data_reader,
        test_source_data: test_scores
    )
  end

  def equity_overview
    @_equity_overview ||= SchoolProfiles::EquityOverview.new(
      school_cache_data_reader: school_cache_data_reader,
      equity: equity
    )
  end

  def academic_progress
    @_academic_progress ||= SchoolProfiles::AcademicProgress.new(
        school,
        school_cache_data_reader: school_cache_data_reader
    )
  end

  def courses
    @_courses ||= SchoolProfiles::Courses.new(
      school_cache_data_reader: school_cache_data_reader
    )
  end

  def stem_courses
    @_stem_courses ||= SchoolProfiles::StemCourses.new(
      school_cache_data_reader: school_cache_data_reader
    )
  end

  def reviews
    # This needs ReviewQuestions for the topical distribution popup
    @_reviews ||= SchoolProfiles::Reviews.new(school, review_questions)
  end

  # For configuring the reviews-on-demand feature. Must return a boolean.
  def reviews_on_demand?
    # The following example shows one way to restrict reviews-on-demand to a set of states.
    # ['ak','ga','il','pa','wa'].include?(@school.state.downcase)

    # Returning true will apply reviews-on-demand to every school profile. False turns it off.
    true
  end

  def show_private_school_template?
    if @school.private_school?
      if ['in'].include?(@school.state.downcase) && (test_scores.visible? || college_readiness.visible?)
        false
      else
        true
      end
    end
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
    [
      {
        text: StructuredMarkup.state_breadcrumb_text(school.state),
        url: state_path(state_params(school.state))
      },
      {
        text: StructuredMarkup.city_breadcrumb_text(state: school.state, city: school.city),
        url: city_path(city_params(school.state, school.city))
      },
      {
        text: t('controllers.school_profile_controller.schools'),
        url: search_city_browse_path(city_params(school.state, school.city))
      },
      {
        text: t('controllers.school_profile_controller.school_profile'),
        url: nil
      }
    ]
  end

  def teachers_staff
    SchoolProfiles::TeachersStaff.new(school_cache_data_reader)
  end

  def osp_school_info
    SchoolProfiles::OspSchoolInfo.new(school, school_cache_data_reader)
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
        :state => school.state,
        :test_scores_only => summary_rating.test_scores_only?
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
    if advertising_enabled?
      # City, compfilter, county, env, gs_rating, level, school_id, State, type, zipcode, district_id, template
      # @school.city.delete(' ').slice(0,10)
      page_view_metadata.each do |key, value|
        ad_targeting_gon_hash[key] = value
      end
    end
  end

  def meta_description
    if school.state.downcase == 'ca'
      content = summary_narration.build_content_with_school_name
      if content.present?
        c = content.join(' ')
        ActionView::Base.full_sanitizer.sanitize(c).truncate(155)
      end
    end
  end

  def modified_recently?(school)
    return true if school.manual_edit_date.nil? && school.modified.nil?
    (school.manual_edit_date && school.manual_edit_date > (Time.now - 4.years)) ||
        (school.modified && school.modified > (Time.now - 4.years))
  end

  def robots
    return 'noindex' if school.demo_school?

    return 'noindex' if show_private_school_template? && !modified_recently?(school) && school.reviews.length < 3

    'index'
  end

  def set_seo_meta_tags
    meta_tags = SchoolProfileMetaTags.new(school)
    description = meta_tags.description
    canonical_url = school_url(school, lang: I18n.current_non_en_locale)

    set_meta_tags title: meta_tags.title,
                  robots: robots,
                  description: description,
                  canonical: canonical_url,
                  alternate: {
                      en: remove_query_params_from_url(canonical_url, [:lang]),
                      es: add_query_params_to_url(canonical_url, true, {lang: :es})
                  },
                  og: {
                      title: "Explore #{school.name} in #{school.city}, #{school.state}",
                      description: "We're an independent nonprofit that provides parents with in-depth school quality information.",
                      site_name: 'GreatSchools.org',
                      image: {
                          url: asset_full_url('assets/share/logo-ollie-large.png'),
                          secure_url: asset_full_url('assets/share/logo-ollie-large.png'),
                          height: 600,
                          width: 1200,
                          type: 'image/png',
                          alt: 'GreatSchools is a non profit organization providing school quality information'

                      },
                      type: 'place',
                      url: school_url(school)
                  },
                  twitter: {
                      image: asset_full_url('assets/share/GreatSchoolsLogo-social-optimized.png'),
                      card: 'Summary',
                      site: '@GreatSchools',
                      description: "We're an independent nonprofit that provides parents with in-depth school quality information."
                  }
  end

  def redirect_to_canonical_url
    # this prevents an endless redirect loop for the profile pages
    # because of ApplicationController::url_options
    canonical_path = remove_query_params_from_url( school_path(school), [:lang] )
    # Add a trailing slash to the request path, only if one doesn't already exist.
    unless canonical_path == with_trailing_slash(request.path)
      redirect_to add_query_params_to_url(
                      school_url(school),
                      true,
                      request.query_parameters
                  ), status: :moved_permanently
    end
  end

  def add_dependencies_to_gon
    gon.dependencies = {
        highcharts: ActionController::Base.helpers.asset_path('highcharts.js')
    }
  end

end
