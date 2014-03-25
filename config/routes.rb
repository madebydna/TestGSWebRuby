LocalizedProfiles::Application.routes.draw do
  require 'states'
  require 'regular_subdomain'
  require 'preschool_subdomain'

  devise_for :admins, path: '/admin/gsr/school-profiles'

  # Routes within this scope are pages not handled by Rails.
  # They are included here so that we can take advantage of the helpful route url helpers, e.g. home_path or jobs_url
  # We need to assign the route a controller action, so just point to page_not_found
  scope '', to: 'error#page_not_found' do
    get '/index.page', as: :home
    get '/about/aboutUs.page', as: :our_mission
    get '/about/senior-management.page', as: :our_people
    get '/jobs/', as: :jobs
    get '/about/feedback.page', as: :contact_us
    get '/about/advertiserOpportunities.page', as: :advertise
    get '/about/partnerOpportunities.page', as: :partners
    get '/about/pressRoom.page', as: :media_room
    get '/about/linkToUs.page', as: :widgets_and_tools
    get '/find-a-school/defining-your-ideal/2423-ratings.gs', as: :how_we_rate_schools
    get '/terms/', as: :terms_of_use
    get '/about/guidelines.page', as: :school_review_guidelines
    get '/privacy/', as: :privacy
    get '/privacy/#advertiserNotice', as: :advertiser_notice
    get '/community/forgotPassword.page', as: :forgot_password
    get '/worksheets-activities.topic?content=4313', as: :worksheets_and_activities
    get '/parenting-dilemmas.topic?content=4321', as: :parenting_dilemmas
    get '/special-education.topic?content=1541', as: :learning_difficulties
    get '/parenting.topic?content=1539', as: :health_and_behavior
    get '/find-schools/', as: :find_schools
    get '/school/parentReview.page', as: :the_scoop
    get '/account/', as: :my_account
    get '/mySchoolList.page', as: :my_school_list
    get '/community/registrationConfirm.page', as: :verify_email
    get '/:state/', constraints: { state: States.any_state_name_regex }, as: :state
    get '/:state/:city/schools/', constraints: { state: States.any_state_name_regex }, as: :school_search
    get '/:state/:city/enrollment/', constraints: { state: States.any_state_name_regex }, as: :enrollment
    get '/official-school-profile/register.page?city=:city&schoolId=:school_id&state=:state', as: :osp_register
    get '/school/QandA/form.page?schoolId=:school_id&state=:state', as: :osp_form
    get '/official-school-profile/dashboard/', as: :osp_dashboard
    get '/school-choice/school-choice/7055-choose-elementary-school-video.gs', as: :help_me_e_video
    get '/school-choice/school-choice/7056-choose-middle-school-video.gs', as: :help_me_m_video
    get '/school-choice/school-choice/7066-choose-high-school-video.gs', as: :help_me_h_video
    get '/catalog/pdf/SpringSweepsRules.pdf', as: :sweepstakes_rules
  end

  namespace :admin, controller: 'admin', path: '/admin/gsr' do
    get '/omniture-test', to: :omniture_test, as: :omniture_test
    get '/info', to: :info
    get '/examples-and-gotchas', to: :examples_and_gotchas

    scope '/school-profiles', as: :school_profiles do
      get '/help', to: 'admin#help'
      mount RailsAdmin::Engine => '', :as => 'rails_admin'
    end

    scope ':state', constraints: { state: States.any_state_name_regex } do
      resources :schools do
        get 'moderate'
      end
    end

    resources :reviews do
      get 'moderation', on: :collection
      match 'publish', on: :member
      match 'disable', on: :member
    end

    resources :held_school
  end

  post '/gsr/review/report/:reported_entity_id', to:'reviews#report', as: :reported_review
  get '/gsr/ajax/reviews_pagination', :to => 'localized_profile_ajax#reviews_pagination'
  # Route to handle ajax "email available" validation
  get '/gsr/validations/email_available', :to => 'user#email_available'
  resources :subscriptions, except: [:destroy, :delete, :index], path: '/gsr/user/subscriptions'
  resources :favorite_schools, except: [:destroy, :delete, :index], path: '/gsr/user/favorites'

  post '/gsr/session/auth', :to => 'signin#create', :as => :authenticate_user
  match '/logout', :to => 'signin#destroy', :as => :logout
  match '/gsr/session/facebook_connect' => 'signin#facebook_connect', :as => :facebook_connect
  match '/gsr/session/facebook_callback' => 'signin#facebook_callback', :as => :facebook_callback
  match '/gsr/session/post_registration_confirmation' => 'signin#post_registration_confirmation', :as => :post_registration_confirmation

  post '/gsr/:state/:city/:schoolId-:school_name/reviews/create', to: 'reviews#create', as: :school_ratings, constraints: {
      state: States.any_state_name_regex,
      schoolId: /\d+/,
      school_name: /.+/
  }

  constraints(RegularSubdomain) do
    get '/join', :to => 'signin#new_join', :as => :join
    get '/gsr/login', :to => 'signin#new', :as => :signin

    # Routes for city page
    scope '/:state/:city', as: :city, constraints: {
        state: States.any_state_name_regex,
    } do

      get '', to: 'cities#show'
      get 'events', to: 'cities#events', as: :events
      get 'choosing-schools', to: 'cities#choosing_schools', as: :choosing_schools
      scope '/education-community', as: :education_community do
        get '', to: 'cities#community'
        get '/education', to: 'cities#community'
        get '/funders', to: 'cities#community'
        get '/partner', to: 'cities#partner', as: :partner
      end
    end

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

  constraints(PreschoolSubdomain) do
    # If a url is on pk subdomain and matches no other routes, remove the pk subdomain and redirect
    match '*path', to: redirect(PreschoolSubdomain.method(:current_url_without_pk_subdomain))
  end


  # error handlers
  match '/error/page_not_found' => 'error#page_not_found', :as => :page_not_found
  match '/error/school_not_found' => 'error#school_not_found', :as => :school_not_found
  match '/error/internal_error' => 'error#internal_error', :as => :internal_error

  # route not found catch-all
  match '*path' => 'error#page_not_found'
end
