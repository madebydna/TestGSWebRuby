LocalizedProfiles::Application.routes.draw do
  require 'states'
  require 'regular_subdomain'
  require 'preschool_subdomain'
  require 'path_with_period'

  mount MochaRails::Engine => 'mocha' unless Rails.env.production?
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
    get '/about/ratings.page', as: :how_we_rate_schools
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
    get '/:state/', constraints: { state: States.any_state_name_regex }, as: :state
    get '/:state/:city/', constraints: { state: States.any_state_name_regex }, as: :city
    get '/:state/:city/choosing-schools/', constraints: { state: States.any_state_name_regex }, as: :choosing_schools
    get '/:state/:city/education-community/', constraints: { state: States.any_state_name_regex }, as: :education_community
    get '/:state/:city/enrollment/', constraints: { state: States.any_state_name_regex }, as: :enrollment
    get '/:state/:city/events/', constraints: { state: States.any_state_name_regex }, as: :events
    get '/official-school-profile/register.page?city=:city&schoolId=:school_id&state=:state', as: :osp_register
    get '/school/QandA/form.page?schoolId=:school_id&state=:state', as: :osp_form
    get '/official-school-profile/dashboard/', as: :osp_dashboard
    get '/school-choice/school-choice/7055-choose-elementary-school-video.gs', as: :help_me_e_video
    get '/school-choice/school-choice/7056-choose-middle-school-video.gs', as: :help_me_m_video
    get '/school-choice/school-choice/7066-choose-high-school-video.gs', as: :help_me_h_video
    get '/catalog/pdf/SpringSweepsRules.pdf', as: :sweepstakes_rules
    get '/understanding-common-core-state-standards.topic?content=7802', as: :common_core
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
  get '/gsr/user/verify', as: :verify_email, to: 'signin#verify_email'

  post '/gsr/:state/:city/:schoolId-:school_name/reviews/create', to: 'reviews#create', as: :school_ratings, constraints: {
      state: States.any_state_name_regex,
      schoolId: /\d+/,
      school_name: /.+/
  }

  constraints(RegularSubdomain) do
    get '/join', :to => 'signin#new_join', :as => :join
    get '/gsr/login', :to => 'signin#new', :as => :signin

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

  constraints(PathWithPeriod) do
    match '*path', to: redirect(PathWithPeriod.method(:url_without_period_in_path))
  end

  # error handlers
  match '/error/page_not_found' => 'error#page_not_found', :as => :page_not_found
  match '/error/school_not_found' => 'error#school_not_found', :as => :school_not_found
  match '/error/internal_error' => 'error#internal_error', :as => :internal_error

  # route not found catch-all
  match '*path' => 'error#page_not_found'




  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
