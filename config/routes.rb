LocalizedProfiles::Application.routes.draw do
  require 'states'
  require 'regular_subdomain'
  require 'preschool_subdomain'
  require 'path_with_period'

  devise_for :admins, path: '/admin/gsr/school-profiles'

  get '/gsr/home', as: :home_prototype, to: 'home#prototype'
  # Route for Search Prototype
  # get '/gsr/search_prototype', as: :search_prototype, to: 'home#search_prototype'

  # Routes for search pages
  get ':state/:city/schools/', as: :search_city_browse,
      constraints: {state: States.any_state_name_regex}, to: 'search#city_browse'

  get '/search/search.page', as: :search, to: 'search#search'

  get '/gsr/search/suggest/school', as: :search_school_suggest, to: 'search#suggest_school_by_name'
  get '/gsr/search/suggest/city', as: :search_city_suggest, to: 'search#suggest_city_by_name'
  get '/gsr/search/suggest/district', as: :search_district_suggest, to: 'search#suggest_district_by_name'

# Routes within this scope are pages not handled by Rails.
  # They are included here so that we can take advantage of the helpful route url helpers, e.g. home_path or jobs_url
  # We need to assign the route a controller action, so just point to page_not_found
  scope '', controller: 'error', action: 'page_not_found' do
    get '/index.page', as: :home
    get '/about/aboutUs.page', as: :our_mission
    get '/about/senior-management.page', as: :our_people
    get '/jobs/', as: :jobs
    get '/about/feedback.page', as: :contact_us
    get '/about/advertiserOpportunities.page', as: :advertise
    get '/about/partnerOpportunities.page', as: :partners
    get '/about/pressRoom.page', as: :media_room
    get '/about/linkToUs.page', as: :widgets_and_tools
    get '/about/ratings.page', as: :how_we_rate_schools
    get '/terms/', as: :terms_of_use
    get '/about/guidelines.page', as: :school_review_guidelines
    get '/privacy/', as: :privacy
    get '/privacy/#advertiserNotice', as: :advertiser_notice
    get '/community/forgotPassword.page', as: :forgot_password
    get '/summer-learning.topic?content=7082', as: :summer_learning
    get '/worksheets-activities.topic?content=4313', as: :worksheets_and_activities
    get '/parenting-dilemmas.topic?content=4321', as: :parenting_dilemmas
    get '/special-education.topic?content=1541', as: :learning_difficulties
    get '/parenting.topic?content=1539', as: :health_and_behavior
    get '/find-schools/', as: :find_schools
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
    get '/schools/cities/:state_long/:state_short/:letter', as: :city_alphabet
  end

  namespace :admin, controller: 'admin', path: '/admin/gsr' do
    get '/omniture-test', to: :omniture_test, as: :omniture_test
    get '/info', to: :info
    get '/examples-and-gotchas', to: :examples_and_gotchas

    scope '/school-profiles', as: :school_profiles do
      get '/help', to: 'admin#help'
      mount RailsAdmin::Engine => '', :as => 'rails_admin'
    end

    scope '/style-guide/', as: :style_guide, to: :style_guide do
      get '/index', to: 'style_guide#index'
    end

    scope ':state', constraints: { state: States.any_state_name_regex } do
      resources :schools do
        get 'moderate'
      end
    end

    resources :reviews do
      get 'moderation', on: :collection
      patch 'publish', on: :member
      patch 'disable', on: :member
      patch 'resolve', on: :member
    end

    resources :held_school
    resources :reported_entity do
      put 'deactivate', on: :member
    end

    resources :data_load_schedules, path: '/data-planning'
  end

  post '/gsr/review/report/:reported_entity_id', to:'reviews#report', as: :reported_review
  get '/gsr/ajax/reviews_pagination', :to => 'localized_profile_ajax#reviews_pagination'
  # Route to handle ajax "email available" validation
  get '/gsr/validations/email_available', :to => 'user#email_available'
  resources :subscriptions, except: [:destroy, :delete, :index], path: '/gsr/user/subscriptions'
  get '/gsr/user/subscriptions', to: 'subscriptions#subscription_from_link', as: 'create_subscription_from_link'
  resources :favorite_schools, except: [:destroy, :delete, :index], path: '/gsr/user/favorites'

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

  constraints(RegularSubdomain) do
    get '/join', :to => 'signin#new_join', :as => :join
    get '/gsr/login', :to => 'signin#new', :as => :signin

    scope '/:state', as: :state, constraints: {
        state: States.any_state_name_regex,
    } do
      get '', to: 'states#show'
      get 'browse', to: 'states#foobar', as: :browse
      get 'choosing-schools', to: 'states#choosing_schools', as: :choosing_schools
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
    end

    # Routes for city page

    # Routes for school profile pages
    scope '/:state/:city/:schoolId-:school_name', as: :school, constraints: {
        state: States.any_state_name_regex,
        schoolId: /\d+/,
        school_name: /.+/,
    } do
      get 'quality', to: 'localized_profile#quality', as: :quality
      get 'details', to: 'localized_profile#details', as: :details
      get 'reviews', to: 'localized_profile#reviews', as: :reviews
      get 'reviews/write', to: 'reviews#new', as: :review_form
      get '', to: 'localized_profile#overview'
    end
  end

  # Handle preschool URLs
  scope '/:state/:city/preschools/:school_name/:schoolId/(/*other)', as: :preschool, constraints: {
      state: States.any_state_name_regex,
      schoolId: /\d+/,
      school_name: /.+/,
  } do

    get 'quality', to: 'localized_profile#quality', as: :quality
    get 'details', to: 'localized_profile#details', as: :details
    get 'reviews', to: 'localized_profile#reviews', as: :reviews
    get 'reviews/write', to: 'reviews#new', as: :review_form
    get '', to: 'localized_profile#overview'
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
