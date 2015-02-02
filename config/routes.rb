
LocalizedProfiles::Application.routes.draw do
  require 'states'
  require 'regular_subdomain'
  require 'preschool_subdomain'
  require 'path_with_period'

  devise_for :admins, path: '/admin/gsr/school-profiles'

  root 'home#show'
  get ENV_GLOBAL['home_path'], as: :home, to: 'home#show'
  # This route ("/gsr/home/") is REQUIRED by Apache as long as we are running Tomcat
  get '/gsr/home', as: :home_show, to: 'home#show'
  # Route for Search Prototype
  # get '/gsr/search_prototype', as: :search_prototype, to: 'home#search_prototype'

  get '/account', as: :manage_account, to: 'account_management#show'

  # get '/schoolreview', as: :review_choose_school, to: 'review_school_chooser#show'

  get '/gsr/schoolreview', as: :review_choose_school, to: 'review_school_chooser#show'

  #get '/gsr/pyoc', to: 'pyoc#print_pdf' , as: :print_pdf

  # Routes for search pages
  get ':state/:city/schools/', as: :search_city_browse,
      constraints: {state: States.any_state_name_regex, city: /[^\/]*/}, to: 'search#city_browse'

  get ':state/:city/:district_name/schools/', as: :search_district_browse,
      constraints: {state: States.any_state_name_regex, district_name: /[^\/]*/}, to: 'search#district_browse'

  get '/search/search.page', as: :search, to: 'search#search'

  resources :saved_searches, only: [:create, :destroy], path: '/gsr/ajax/saved_search'

  get '/compare', as: :compare_schools, to: 'compare_schools#show'


  get '/gsr/search/suggest/school', as: :search_school_suggest, to: 'search#suggest_school_by_name'
  get '/gsr/search/suggest/city', as: :search_city_suggest, to: 'search#suggest_city_by_name'
  get '/gsr/search/suggest/district', as: :search_district_suggest, to: 'search#suggest_district_by_name'
  get '/gsr/ajax/search/calculate_fit', as: :search_calculate_fit, to: 'search_ajax#calculate_school_fit'
  get '/gsr/user/account_subscriptions', to: 'subscriptions#create_subscription_from_account_page', as: 'create_subscription_from_account_page'


# Routes within this scope are pages not handled by Rails.
  # They are included here so that we can take advantage of the helpful route url helpers, e.g. home_path or jobs_url
  # We need to assign the route a controller action, so just point to page_not_found
  scope '', controller: 'error', action: 'page_not_found' do
    get '/about/aboutUs.page', as: :our_mission
    get '/about/senior-management.page', as: :our_people
    get '/jobs/', as: :jobs
    get '/about/feedback.page', as: :contact_us
    get '/about/advertiserOpportunities.page', as: :advertise
    get '/about/partnerOpportunities.page', as: :partners
    get '/about/pressRoom.page', as: :media_room
    get '/about/linkToUs.page', as: :widgets_and_tools
    get '/about/licensing.page', as: :licensing
    get '/about/ratings.page', as: :how_we_rate_schools
    get '/terms/', as: :terms_of_use
    get '/about/guidelines.page', as: :school_review_guidelines
    get '/privacy/', as: :privacy
    get '/about/gsFaq.page', as: :faq
    # get '/community/forgotPassword.page', as: :forgot_password
    get '/back-to-school/', as: :back_to_school
    get '/worksheets-activities.topic?content=4313', as: :worksheets_and_activities
    get '/parenting-dilemmas.topic?content=4321', as: :parenting_dilemmas
    get '/special-education.topic?content=1541', as: :learning_difficulties
    get '/parenting.topic?content=1539', as: :health_and_behavior
    get '/school/parentReview.page', as: :the_scoop
    get '/account/', as: :my_account
    get '/mySchoolList.page', as: :my_school_list
    get '/official-school-profile/register.page?city=:city&schoolId=:school_id&state=:state', as: :osp_register
    get '/school/QandA/form.page?schoolId=:school_id&state=:state', as: :osp_form
    get '/official-school-profile/dashboard/', as: :osp_dashboard
    get '/school-choice/school-choice/7055-choose-elementary-school-video.gs', as: :help_me_e_video
    get '/school-choice/school-choice/7056-choose-middle-school-video.gs', as: :help_me_m_video
    get '/school-choice/school-choice/7066-choose-high-school-video.gs', as: :help_me_h_video
    get '/catalog/pdf/SpringSweepsRules.pdf', as: :sweepstakes_rules
    get '/understanding-common-core-state-standards.topic?content=7802', as: :common_core
    get '/healthy-kids.topic?content=2504', as: :health_and_wellness_article
    get '/college/', as: :college_articles
    get '/STEM.topic?content=8021', as: :stem_article
    get '/schools/cities/:state_long/:state_short/:letter', as: :city_alphabet
    get '/schools/cities/:state_long/:state_short', as: :city_list
    get '/schools/districts/:state_long/:state_short', as: :district_list
    get '/school-district-boundaries-map/', as: :district_boundary
    get '/about/guidelines.page', as: :review_guidelines
    get '/moving.topic?content=2220', as: :moving
    get '/gifted-and-advanced-learners.topic?content=8038', as: :advanced_learners
    get '/OECDTestForSchools.page', as: :oecd_landing
    get '/gk/milestones/', as: :gk_milestones
  end

  namespace :admin, controller: 'admin', path: '/admin/gsr' do
    get '/omniture-test', to: :omniture_test, as: :omniture_test
    get '/info', to: :info
    get '/examples-and-gotchas', to: :examples_and_gotchas

    scope '/school-profiles', as: :school_profiles do
      get '/help', to: 'admin#help'
      mount RailsAdmin::Engine => '', :as => 'rails_admin'
    end

    get '/style-guide/*page', to: 'style_guide#index'
    get '/style-guide/', to: 'style_guide#index'
    get '/pyoc', to: 'pyoc#print_pdf'
    get '/choose-pyoc', to: 'pyoc#choose'

    post '/reviews/ban_ip' , to:'reviews#ban_ip', as: :ban_ip

    scope ':state', constraints: { state: States.any_state_name_regex } do
      resources :schools do
        get 'moderate'
      end
    end

    resources :reviews do
      get 'moderation', on: :collection
      get 'schools', on: :collection
      get 'users', on: :collection
      put 'publish', on: :member
      put 'disable', on: :member
      put 'resolve', on: :member
      put 'report', on: :member
    end

    resources :held_school
    resources :reported_entity do
      put 'deactivate', on: :member
    end

    resources :data_load_schedules, path: '/data-planning'
  end

  post '/gsr/review/report/:reported_entity_id', to:'reviews#report', as: :reported_review
  get '/gsr/ajax/reviews_pagination', :to => 'localized_profile_ajax#reviews_pagination'
  get '/gsr/ajax/get_cities', :to => 'simple_ajax#get_cities'
  get '/gsr/ajax/get_schools', :to => 'simple_ajax#get_schools'
  get '/gsr/ajax/get_school_and_forward', to: 'simple_ajax#get_school_and_forward', as: :get_school_and_forward
  get '/gsr/ajax/create_helpful_review', :to => 'simple_ajax#create_helpful_review'
  get '/gsr/validations/email_provisional', :to => 'user#email_provisional_validation'
  get '/gsr/user/send_verification_email', :to => 'user#send_verification_email'
  # Route to handle ajax "email available" validation
  get '/gsr/validations/email_available', :to => 'user#email_available'
  get '/gsr/user/save_city_state', :to => 'user#update_user_city_state'
  get '/gsr/user/save_grade_selection', :to => 'user#update_user_grade_selection'
  get '/gsr/user/delete_grade_selection', :to => 'user#delete_user_grade_selection'
  put '/gsr/user/change-password', to: 'user#change_password', as: :change_password
  resources :subscriptions, except: [:index], path: '/gsr/user/subscriptions'
  get '/gsr/user/subscriptions', to: 'subscriptions#subscription_from_link', as: 'create_subscription_from_link'
  resources :favorite_schools, except: [:index], path: '/gsr/user/favorites'

  post '/gsr/session/auth', :to => 'signin#create', :as => :authenticate_user
  match '/logout', :to => 'signin#destroy', :as => :logout, via: [:get, :post, :delete]
  match '/gsr/session/facebook_connect' => 'signin#facebook_connect', :as => :facebook_connect, via: [:get, :post]
  match '/gsr/session/facebook_callback' => 'signin#facebook_callback', :as => :facebook_callback, via: [:get, :post]
  match '/gsr/session/post_registration_confirmation' => 'signin#post_registration_confirmation', :as => :post_registration_confirmation, via: [:get, :post]
  get '/gsr/user/verify', as: :verify_email, to: 'signin#verify_email'

  post '/gsr/:state/:city/:schoolId-:school_name/reviews/create', to: 'reviews#create', as: :school_ratings, constraints: {
      state: States.any_state_name_regex,
      schoolId: /\d+/,
      school_name: /.+/
  }

  get '/gsr/:state/:city/:district', to: 'districts#show', as: :district, constraints: lambda{ |request|
    district = request.params[:district]
    # district can't = preschools and must start with letter
    return district != 'preschools' && district.match(/^[a-zA-Z].*$/)
  }

  get '/gsr/reset-password',:as => :reset_password, :to => 'forgot_password#allow_reset_password'
  get '/gsr/forgot-password', :to => 'forgot_password#show', :as => 'forgot_password'
  post '/gsr/forgot-password/send_reset_email', :to => 'forgot_password#send_reset_password_email', :as => 'send_reset_password_email'

  constraints(RegularSubdomain) do
    get '/join', :to => 'signin#new_join', :as => :join
    get '/gsr/login', :to => 'signin#new', :as => :signin

    scope '/:state', as: :state, constraints: {
        state: States.any_state_name_regex,
    } do
      get '', to: 'states#show'
      get 'browse', to: 'states#foobar', as: :browse
      get 'choosing-schools', to: 'states#choosing_schools', as: :choosing_schools
      get 'guided-search', to: 'states#guided_search', as: :guided_search
      get 'events', to: 'states#events', as: :events



      get 'enrollment', to: 'states#enrollment', as: :enrollment
      scope '/enrollment', as: :enrollment do
        get '/:tab', to: 'states#enrollment'
      end

      scope '/education-community', as: :education_community do
        get '', to: 'states#community'
        get '/education', to: 'states#community'
        get '/funders', to: 'states#community'
        get '/partner', to: 'states#community', as: :partner
      end
    end

    scope '/:state/:city', as: :city, constraints: {
        state: States.any_state_name_regex,
    } do

      get '', to: 'cities#show'
      get 'events', to: 'cities#events', as: :events
      get 'choosing-schools', to: 'cities#choosing_schools', as: :choosing_schools
      get 'enrollment', to: 'cities#enrollment', as: :enrollment
      get 'schools', to: 'error#page_not_found', as: :browse
      get 'guided-search', to: 'cities#guided_search', as: :guided_search

      scope '/enrollment', as: :enrollment do
        get '/:tab', to: 'cities#enrollment'
      end
      get 'programs', to: 'cities#programs', as: :programs

      scope '/education-community', as: :education_community do
        get '', to: 'cities#community'
        get '/education', to: 'cities#community'
        get '/funders', to: 'cities#community'
        get '/partner', to: 'cities#partner', as: :partner
      end

      # Route to district home. Java will handle this, so set controller
      # to just 404 by default. route helper will be city_district_path(...)
      # NOTE: this must come last in the city scope, because it will match
      # Anything after the cty name
      get '/:district', to: 'districts#show', as: :district, constraints: lambda{ |request|
        district = request.params[:district]
        # district can't = preschools and must start with letter
        return district != 'preschools' && district.match(/^[a-zA-Z].*$/)
      }
    end

    # Routes for city page

    # Routes for school profile pages
    scope '/:state/:city/:schoolId-:school_name', as: :school, constraints: {
        state: States.any_state_name_regex,
        schoolId: /\d+/,
        school_name: /.+/,
    } do
      get 'quality', to: 'school_profile_quality#quality', as: :quality
      get 'details', to: 'school_profile_details#details', as: :details
      get 'reviews', to: 'school_profile_reviews#reviews', as: :reviews
      get 'reviews/write', to: 'reviews#new', as: :review_form
      get '', to: 'school_profile_overview#overview'
    end
  end

  # Handle preschool URLs
  scope '/:state/:city/preschools/:school_name/:schoolId/(/*other)', as: :preschool, constraints: {
      state: States.any_state_name_regex,
      schoolId: /\d+/,
      school_name: /.+/,
  } do

    get 'quality', to: 'school_profile_quality#quality', as: :quality
    get 'details', to: 'school_profile_details#details', as: :details
    get 'reviews', to: 'school_profile_reviews#reviews', as: :reviews
    get 'reviews/write', to: 'reviews#new', as: :review_form
    get '', to: 'school_profile_overview#overview'
  end

  constraints(PathWithPeriod) do
    match '*path', to: redirect(PathWithPeriod.method(:url_without_period_in_path)), via: [:get, :post]
  end

  constraints(PreschoolSubdomain) do
    # If a url is on pk subdomain and matches no other routes, remove the pk subdomain and redirect
    match '*path', to: redirect(PreschoolSubdomain.method(:current_url_without_pk_subdomain)), via: [:get, :post]
  end

  # error handlers
  match '/error/page_not_found' => 'error#page_not_found', :as => :page_not_found, via: [:get, :post]
  match '/error/school_not_found' => 'error#school_not_found', :as => :school_not_found, via: [:get, :post]
  match '/error/internal_error' => 'error#internal_error', :as => :internal_error, via: [:get, :post]

  # route not found catch-all
  match '*path' => 'error#page_not_found', via: [:get, :post]
end
