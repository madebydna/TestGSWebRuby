
LocalizedProfiles::Application.routes.draw do
  require 'states'

  root 'home#show'
  get ENV_GLOBAL['home_path'], as: :home, to: 'home#show'

  get '/account', as: :manage_account, to: 'account_management#show'

  get '/gsr/typeahead/'=> 'typeahead#show',  as: :typeahead

  # change to /reviews/?topic=1
  get '/reviews/', as: :review_choose_school, to: 'review_school_chooser#show'
  get '/morgan-stanley/', as: :morgan_stanley, to: 'review_school_chooser#morgan_stanley'

  # This city regex allows for all characters except /
  # http://guides.rubyonrails.org/routing.html#specifying-constraints
  city_regex = /[^\/]+/

  # Routes for search pages
  get ':state/schools/', constraints: { state: States.any_state_name_regex }, as: :search_state_browse, to: 'search#search'
  get ':state/:city/schools/', constraints: { state: States.any_state_name_regex, city: city_regex }, as: :search_city_browse, to: 'search#search'
  get ':state/:city/:level/',
      constraints: {state: States.any_state_name_regex, city: /[^\/]+/,
                    level: /preschools|elementary-schools|middle-schools|high-schools/},
      to: redirect {|params, request| "#{request.path.chomp('/').concat('/').sub("/#{params[:level]}/", '/schools/')}?gradeLevels=#{params[:level][0]}" }
  get ':state/:city/:type/schools/',
      constraints: {state: States.any_state_name_regex, city: /[^\/]+/,
                    type: /public|public-charter|private/},
      to: redirect {|params, request| "#{request.path.chomp('/').concat('/').sub("/#{params[:type]}/", '/')}?st=#{params[:type].split('-').last}" }
  get ':state/:city/:type/:level/',
      constraints: {state: States.any_state_name_regex, city: /[^\/]+/,
                    type: /public|public-charter|private/,
                    level: /preschools|elementary-schools|middle-schools|high-schools/},
      to: redirect {|params, request| "#{request.path.chomp('/').sub("/#{params[:type]}/#{params[:level]}", '/schools/')}?gradeLevels=#{params[:level][0]}&st=#{params[:type].split('-').last}" }
  get ':state/:city/:district_name/schools/', constraints: { state: States.any_state_name_regex, city: /[^\/]+/, district_name: /[^\/]+/ }, as: :search_district_browse, to: 'search#search'
  # This city regex allows for all characters except /
  # http://guides.rubyonrails.org/routing.html#specifying-constraints
  get ':state/:city/:district_name/:level/',
      constraints: {state: States.any_state_name_regex, city: /[^\/]+/, district_name: /[^\/]+/,
                    level: /preschools|elementary-schools|middle-schools|high-schools/},
      to: redirect {|params, request| "#{request.path.chomp('/').concat('/').sub("/#{params[:level]}/", '/schools/')}?gradeLevels=#{params[:level][0]}" }
  get ':state/:city/:district_name/:type/schools/',
      constraints: {state: States.any_state_name_regex, city: /[^\/]+/, district_name: /[^\/]+/,
                    type: /public|public-charter|private/},
      to: redirect {|params, request| "#{request.path.chomp('/').concat('/').sub("/#{params[:type]}/", '/')}?st=#{params[:type].split('-').last}" }
  get ':state/:city/:district_name/:type/:level/',
      constraints: {state: States.any_state_name_regex, city: /[^\/]+/, district_name: /[^\/]+/,
                    type: /public|public-charter|private/,
                    level: /preschools|elementary-schools|middle-schools|high-schools/},
      to: redirect {|params, request| "#{request.path.chomp('/').sub("/#{params[:type]}/#{params[:level]}", '/schools/')}?gradeLevels=#{params[:level][0]}&st=#{params[:type].split('-').last}" }

  # referenced as search_path in old top nav (deprecated_application) layout
  scope '/search/search.page', as: :search do
    get '', to: 'search#search'
  end

  get 'search/search.zipcode', as: :zipcode_browse, to: 'search#search'

  get '/find-schools/', as: :default_search, to: redirect('/')

  # Add/remove school routes
  match '/add_school', to: 'add_schools#new', via: :get
  match '/add_school', to: 'add_schools#create', via: :post
  match '/remove_school', to: 'remove_schools#new', via: :get
  match '/remove_school', to: 'remove_schools#create', via: :post

  get '/school_change_request/success', as: :new_remove_school_submission_success, to: 'add_schools#success'

  resources :user_preferences, only: [:edit]

  # Alternative preferences routes
  get '/preferences/' => 'user_email_preferences#show', as: 'user_preferences'
  post '/preferences/' => 'user_email_preferences#update', as: 'user_preferences_update'
  post '/unsubscribe/' => 'user_email_unsubscribes#create', as: 'user_email_unsubscribes'
  get '/unsubscribe/' => 'user_email_unsubscribes#new', as: 'unsubscribe'


  get '/newsletter/' => 'user_signup#show', as: 'user_signup'
  get '/espanol/' => 'user_signup#show_spanish', as: 'user_signup_spanish'
  post '/newsletter/' => 'user_signup#create', as: 'user_signup_submit'
  post '/espanol/' => 'user_signup#create', as: 'user_signup_submit_spanish'
  get '/newsletter/' => 'user_signup#thankyou', as: 'user_signup_confirmation'
  get '/espanol/' => 'user_signup#thankyou', as: 'user_signup_confirmation_spanish'

  get '/compare', as: :compare_schools, to: 'compare_schools#show'

  # OSP routes
  get  '/school/esp/form.page', to: 'osp#show' , as: :osp_page
  ## Deprecated OSP routes.
  ## TODO: Plans to remove from config files
  get '/official-school-profile/', to: redirect('/school-accounts/')
  get '/official-school-profile/register.page', to: redirect('/school-accounts/register.page')
  get '/official-school-profile/dashboard/', to: redirect('/school-accounts/dashboard/')
  get '/official-school-profile/registration-confirmation', to: redirect('/school-accounts/registration-confirmation')
  ## New OSP routes
  get '/school-accounts/', to: 'osp_landing#show',as: :osp_landing
  match '/school-accounts/register.page', to: 'osp_registration#new', as: :osp_registration, via: [:get]
  match '/school-accounts/register.page', to: 'osp_registration#submit', as: :osp_registration_submit, via: [:post]
  get '/school-accounts/dashboard/', to: 'osp_landing#dashboard', as: :osp_dashboard
  get '/school-accounts/registration-confirmation', to: 'osp_confirmation#show',as: :osp_confirmation
  post  '/school/esp/submit_form.page', to: 'osp#submit' , as: :osp_submit

  # Search autocomplete suggestion routes
  get '/gsr/search/suggest/school', as: :search_school_suggest, to: 'search#suggest_school_by_name'
  get '/gsr/search/suggest/city', as: :search_city_suggest, to: 'search#suggest_city_by_name'
  get '/gsr/search/suggest/district', as: :search_district_suggest, to: 'search#suggest_district_by_name'

  # For WP footer/header integration
  get '/gsr/footer', to: 'footer#show'
  get '/gsr/header', to: 'header#show'

  # Widget routes
  get '/widget/', :to => 'widget#show', as: :widget
  post '/widget/', :to => 'widget#create'
  match '/widget/map' => 'widget#map_and_links', via: [:get, :post]
  match '/widget/schoolSearch.page' => 'widget#map', via: [:get, :post]

  # Routes within this scope are pages not handled by Rails.
  # They are included here so that we can take advantage of the helpful route url helpers, e.g. home_path or jobs_url
  # We need to assign the route a controller action, so just point to page_not_found
  scope '', controller: 'error', action: 'page_not_found' do
    get '/gk/', as: :greatkids_home
    get '/about/aboutUs.page', as: :our_mission
    get '/about/senior-management.page', as: :our_people
    get '/jobs/', as: :jobs
    get '/gk/contact/', as: :contact_us
    get '/about/advertiserOpportunities.page', as: :advertise
    get '/about/partnerOpportunities.page', as: :partners
    get '/about/pressRoom.page', as: :media_room
    get '/about/linkToUs.page', as: :widgets_and_tools
    get '/about/licensing.page', as: :licensing
    get '/about/ratings.page', as: :how_we_rate_schools
    get '/gk/terms/', as: :terms_of_use
    get '/gk/about/api-terms-use', as: :api_terms_of_use
    get '/gk/review-guidelines', as: :school_review_guidelines
    get '/gk/privacy/', as: :privacy
    get '/gk/faq/', as: :faq
    get '/gk/back-to-school/', as: :back_to_school
    get '/gk/parent-power/', as: :parent_power
    get '/gk/ratings/', as: :school_ratings
    get '/gk/reviews/', as: :gk_school_reviews
    get '/gk/worksheets/', as: :worksheets_and_activities
    get '/gk/category/dilemmas/', as: :parenting_dilemmas
    get '/gk/emotional-smarts/', as: :emotional_smarts
    get '/gk/road-to-college/', as: :road_to_college
    get '/gk/category/learning-disabilities/', as: :learning_disabilities
    get '/parenting.topic?content=1539', as: :health_and_behavior
    get '/gk/common-core-test-guide/', as: :common_core_test_guide
    # TODO: see how to fix this route for ruby
    get '/reviews/', as: :the_scoop
    get '/account/', as: :my_account
    get '/school-accounts/register.page?city=:city&schoolId=:school_id&state=:state', as: :osp_register
    get '/school/QandA/form.page?schoolId=:school_id&state=:state', as: :osp_form
    get '/gk/videos/choose-elementary-school-video/', as: :help_me_e_video
    get '/gk/videos/choose-middle-school-video/', as: :help_me_m_video
    get '/gk/videos/choose-high-school-video/', as: :help_me_h_video
    get '/catalog/pdf/SpringSweepsRules.pdf', as: :sweepstakes_rules
    get '/understanding-common-core-state-standards.topic?content=7802', as: :common_core
    get '/healthy-kids.topic?content=2504', as: :health_and_wellness_article
    get '/gk/road-to-college/', as: :college_articles
    get '/STEM.topic?content=8021', as: :stem_article
    # get '/schools/cities/:state_long/:state_short/:letter', as: :city_alphabet
    # get '/schools/cities/:state_long/:state_short', as: :city_list
    # get '/schools/districts/:state_long/:state_short', as: :district_list
    get '/about/guidelines.page', as: :review_guidelines
    get '/gk/moving-with-kids/', as: :moving
    get '/gifted-and-advanced-learners.topic?content=8038', as: :advanced_learners
    get '/gk/category/early-learning/', as: :early_learning
    get '/gk/summer-learning/', as: :summer_planning
    get '/gk/summer-learning/', as: :summer_learning
    get '/OECDTestForSchools.page', as: :oecd_landing
    get '/gk/milestones/', as: :gk_milestones
    get '/gk/levels/high-school/', as: :gk_levels_high_school
    get '/gk/cue-cards/', as: :gk_cue_cards
    get '/gk/levels/high-school-es/', as: :gk_levels_high_school_es
    get '/gk/summary-rating/', as: :summary_rating
    get '/gk/grade-by-grade-newsletter/', as: :grade_by_grade_newsletter
    get '/gk/about/research-reports/', as: :research_reports

    get '/gk/articles/imagining-your-ideal-school-set-your-priorities/', as: :ideal_school
    get '/gk/articles/redshirting-kindergarten/', as: :when_to_start_kindergarten
    get '/gk/articles/switch-or-stay-schools-early-in-year/', as: :switch_schools
    get '/gk/articles/skipping-a-grade-pros-and-cons/', as: :skipping_grades
    get '/gk/articles/preschool-philosophies/', as: :preschool_philosophies
    get '/gk/videos/second-language-education-video/', as: :second_language_video
    get '/gk/videos/quick-guide-special-education-video-2/', as: :special_ed_video
    get '/gk/articles/special-education-special-needs-learning-disabilities/', as: :special_needs_programs
    get '/gk/articles/help-your-child-with-the-transition/', as: :moving_tips
    get '/gk/articles/gifted-and-talented-education-and-program/', as: :gifted_education
    get '/gk/articles/sizing-up-school-safety/', as: :school_safety
    get '/gk/articles/public-private-charter-schools/', as: :public_private_charter
    get '/gk/articles/school-choice-your-options/', as: :school_choice_options
    get '/gk/articles/private-vs-public-schools/', as: :private_vs_public
    get '/gk/articles/school-terminology/', as: :school_terminology
    get '/gk/articles/public-school/', as: :public_school_facts
    get '/gk/videos/what-is-charter-school-video/', as: :charter_school_video
    get '/gk/articles/charter-schools-2/', as: :truth_about_charter
    get '/gk/articles/seven-facts-about-charter-schools/', as: :seven_charter_facts
    get '/gk/articles/charter-schools-better-than-traditional/', as: :charter_vs_traditional
    get '/gk/videos/private-schools-video/', as: :private_schools_video
    get '/gk/articles/private-schools-parochial-schools/', as: :private_school_facts
    get '/gk/videos/school-test-scores-video/', as: :test_scores_video
    get '/gk/articles/cultural-diversity-at-school/', as: :cultural_diversity
    get '/gk/articles/class-size/', as: :class_size
    get '/gk/articles/school-size/', as: :school_size
    get '/preschool/slideshows/7268-why-preschool.gs', as: :why_preschool
    get '/gk/articles/mistakes-choosing-preschool/', as: :mistakes_choosing_preschool
    get '/gk/articles/mistakes-choosing-elementary/', as: :mistakes_choosing_elementary
    get '/gk/articles/mistakes-choosing-middle-school/', as: :mistakes_choosing_middle
    get '/gk/articles/mistake-choosing-highschool/', as: :mistakes_choosing_high
    get '/gk/articles/the-school-visit-what-to-look-for-what-to-ask/', as: :school_visit
    get '/gk/articles/choosing-a-school-from-a-distance/', as: :school_from_distance
    get '/find-a-school/slideshows/3457-choosing-a-preschool.gs', as: :choose_preschool_slideshow
    get '/gk/articles/insider-tricks-for-assessing-preschools/', as: :assessing_preschools
    get '/gk/videos/choose-elementary-school-video/', as: :choose_elementary_video
    get '/find-a-school/slideshows/3469-choosing-an-elementary-school.gs', as: :choose_elementary_slideshow
    get '/gk/articles/insider-tricks-for-assessing-elementary-schools/', as: :assessing_elementary
    get '/gk/videos/choose-middle-school-video/', as: :choose_middle_video
    get '/find-a-school/slideshows/3436-choosing-a-middle-school.gs', as: :choose_middle_slideshow
    get '/gk/articles/insider-tricks-for-assessing-middle-schools/', as: :assessing_middle
    get '/gk/videos/choose-high-school-video/', as: :choose_high_video
    get '/find-a-school/slideshows/3446-choosing-a-high-school.gs', as: :choose_high_slideshow
    get '/gk/articles/insider-tricks-for-assessing-high-schools/', as: :assessing_high
    get '/gk/articles/like-a-sponge/', as: :podcasts
    get '/gk/articles/cool-school-models/', as: :innovative_schools
    get '/gk/partners', as: :gk_partners
    get '/gk/licensing', as: :gk_licensing
    get '/gk/sponsorship', as: :sponsorship
    get '/gk/advertising', as: :advertising
    get '/gk/careers', as: :careers
    get '/gk/supporters', as: :supporters
    get '/gk/about', as: :about
    get '/gk/category/school-life/', as: :school_life
    get '/gk/category/academics/reading-2/', as: :reading
    get '/gk/category/academics/math-2/', as: :math
    get '/gk/articles/the-achievement-gap-is-your-school-helping-all-students-succeed/', as: :article_achievement_gap
    get '/gk/ratings/',  as: :ratings
    get '/gk/como-clasificamos/',  as: :ratings_spanish
    get '/gk/csa-winners/', as: :csa_winners
    get '/gk/coronavirus-school-closure-support/', as: :coronavirus
    get '/status/error404.page'
  end

  # API key request routes
  get '/api/request-api-key/', to: 'admin/api_accounts#register', as: :request_api_key
  get '/api/request-api-key/success/', to: 'admin/api_accounts#success', as: :request_api_key_success
  post '/api/request-api-key/', to: 'admin/api_accounts#create_api_account', as: :post_request_api_key

  # New API routes
  get '/api/signup/', to: 'admin/api/users#new', as: :api_signup
  post '/api/signup/', to: 'admin/api/users#create'
  patch '/api/billing/:id', to: 'admin/api/users#update', as: :api_billing_update
  get '/api/billing/', to: 'admin/api/users#billing', as: :api_billing


  namespace :api, controller: 'api', path:'/gsr/api' do
    resource :session
    resource :school_user_digest
    resource :nearby_schools
    resources :schools
    get '/reviews_list', to: 'reviews#reviews_list', as: :reviews_list
    resources :reviews do
      get 'count', on: :collection
    end
    resources :districts
    resource :widget_logs, only: [:create]
    resources :students, only: [:show, :create]
    resources :subscriptions, only: [:create, :destroy]
    get '/autosuggest', to: 'autosuggest#show'
    post '/save_school', to: 'saved_schools#create'
    delete '/delete_school', to: 'saved_schools#destroy'
    post '/log_saved_school', to: 'saved_schools_log#create'
  end

  # API documentation route
  match '/api/docs/:page', to: 'api_documentation#show', via: [:get], as: :api_docs

  get '/admin/gsr/widget-test', to: 'widget#test'

  namespace :admin, controller: 'admin', path: '/admin/gsr' do
    resources :api_accounts, except: [:show, :destroy]
    post '/api_accounts/create_api_key', to: 'api_accounts#create_api_key', as: :create_api_key
    get '/info', action: :info
    get '/examples-and-gotchas', action: :examples_and_gotchas

    scope '/school-profiles', as: :school_profiles do
      get '/:state/:schoolId', action: :attributes, constraints: {
        state: States.route_friendly_any_state_abbreviation_regex,
        schoolId: /\d+/
      }
      post '/:state/:schoolId/update', to: 'admin#update_school', as: :update
    end

    get '/user-help/', to: 'users#user_help'

    post '/reviews/ban_ip' , to:'reviews#ban_ip', as: :ban_ip
    get '/first-active-school-url-per-state', to: 'first_active_school_url_per_state#show'

    get '/script-query', action: :script_query

    scope ':state', constraints: { state: States.any_state_name_regex } do
      resources :schools, only: [] do # admin#schools only has moderate action
        get 'moderate'
      end
    end

    # Admin review routes
    resources :reviews, only: [:update] do
      get 'moderation', on: :collection
      get 'schools', on: :collection
      get 'users', on: :collection
      put 'activate', on: :member
      put 'deactivate', on: :member
      put 'resolve', on: :member
      put 'flag', on: :member
    end

    resources :review_notes, only: [:create]

    # Passwords:
    # This route allows a moderator to generate a URL. The page is refreshed and said URL is displayed on page
    # When a GET request is made to the URL, a "forgot password" email (with another link) will be emailed to the user
    # so they can get to the "reset password" form
    # Thought from SS: I wonder why we do this, rather than immediately sending the "forgot password" email to the user
    get  '/reset_password', to: 'users#generate_reset_password_link' , as: :generate_reset_password_link

    get  '/users/search'

    resources :held_school, only: [:create, :update, :destroy] do
      member do
        put 'remove_hold'
      end
    end

    resources :data_load_schedules, path: '/data-planning'

    get '/duplicate-membership', to: 'osp_demigod#show'
    post '/duplicate-membership', to: 'osp_demigod#create'
  end
  # end admin namespace

  # OSP moderation routes
  # controller, routes and views should move under admin namespace
  get '/admin/gsr/osp-moderation', to: 'osp_moderation#index', as: :osp_moderation_index
  post '/admin/gsr/osp-moderation', to: 'osp_moderation#update', as: :osp_moderation_update
  get '/admin/gsr/osp-search', to: 'osp_moderation#osp_search', as: :osp_search
  get '/admin/gsr/osp/:id', to: 'osp_moderation#edit', as: :osp_edit
  post '/admin/gsr/osp/:id', to: 'osp_moderation#update_osp_list_member', as: :osp_update_list_member

  # WP route
  post '/gsr/ajax/wordpress_submit', to: 'wordpress_interface#call_from_wordpress', as: :call_from_wordpress

  # Review routes with /gsr prefix
  post '/gsr/reviews/:id/flag', to: 'reviews#flag', as: :flag_review
  post '/gsr/reviews/', to: 'reviews#create', as: :create_reviews

  get '/gsr/ajax/get_cities_alphabetically', :to => 'simple_ajax#get_cities_alphabetically'
  get '/gsr/ajax/get_schools_with_link', :to => 'simple_ajax#get_schools_with_link'

  # User-related routes
  get '/gsr/validations/validate_user_can_log_in', :to => 'user#validate_user_can_log_in'
  get '/gsr/user/send_verification_email', :to => 'user#send_verification_email'
  # Route to handle ajax "email available" validation
  get '/gsr/validations/email_available', :to => 'user#email_available'
  get '/gsr/validations/need_to_signin', :to => 'user#need_to_signin'
  post '/gsr/user/save_grade_selection', :to => 'user#update_user_grade_selection'
  post '/gsr/user/delete_grade_selection', :to => 'user#delete_user_grade_selection'
  post '/gsr/user/send_verify_email', :to => 'user#send_verify_email_admin'
  post '/gsr/user/send_reset_password_email', :to => 'user#send_reset_password_email_admin'
  resources :subscriptions, only: [:create, :destroy], path: '/gsr/user/subscriptions'
  resources :favorite_schools, only: [:create, :destroy], path: '/gsr/user/favorites'

  # Routes to trigger modals
  get '/gsr/modals/signup_and_follow_school_modal',:to=> 'modals#signup_and_follow_school_modal', as: :signup_and_follow_school_modal
  get '/gsr/modals/school_user_modal',:to=> 'modals#school_user_modal', as: :school_user_modal
  get '/gsr/modals/dependencies', to: 'modals#dependencies'
  get '/gsr/modals/:modal', to: 'modals#show', as: :modal

  # Loaded from WP
  get '/gsr/assets', to: 'assets#show'

  # User authentication routes
  post '/gsr/session/auth', :to => 'signin#create', :as => :authenticate_user
  match '/gsr/session/register_email', to: 'signin#register_email_unless_exists', :as => :register_email, via: [:post]
  match '/logout', :to => 'signin#destroy', :as => :logout, via: [:get, :post, :delete]
  match '/gsr/session/facebook_auth' => 'signin#facebook_auth', :as => :facebook_auth, via: [:get, :post]
  match '/gsr/session/post_registration_confirmation' => 'signin#post_registration_confirmation', :as => :post_registration_confirmation, via: [:get, :post]
  # This route needs to be either merged with authenticate_token, or renamed to be more consistent with that one
  # JIRA: JT-385
  get '/gsr/user/verify', as: :verify_email, to: 'signin#verify_email'
  get '/gsr/user/user-status', as: :user_login_verification_status, to: 'user#user_login_verification_status'
  get '/join', :to => 'signin#new_join', :as => :join
  get '/gsr/login', :to => 'signin#new', :as => :signin

  # My school list route
  get '/my-school-list', to: 'my_school_list#show', as: :my_school_list

  # Password routes
  # Authenticates the user using a hash, and then redirects
  # Example usage: send user here when they click a link in a "forgot password" email
  get '/gsr/authenticate-token', :as => :authenticate_token, :to => 'signin#authenticate_token_and_redirect'
  # When this route is requested, we will deliver a form to the user, where they will provide their email address
  # so that we can send them a "forgot password" link
  get '/account/forgot-password', :to => 'forgot_password#show', :as => 'forgot_password'
  # When this route is requested, the user is telling us that they have forgotten their password,
  # and need a "forgot password" email. We'll send them an email with a link, and that link will allow us to
  # authenticate them so they can go ahead and change their password
  post '/account/forgot-password', :to => 'forgot_password#send_reset_password_email'
  # This route handles a user's "reset password" post. When they submit a form with their new password, it posts here
  post '/account/password', to: 'password#update', as: :password
  # When this route is requested, we should deliver a page with a form that allows the user to type in and confirm
  # a new password. The user must be logged in before they can see this form
  get '/account/password', to: 'password#show'

  # District Boundary route
  get '/school-district-boundaries-map', as: :district_boundary, to: 'district_boundaries#show'

  # State routes
  scope '/:state', as: :state, constraints: {
      state: States.any_state_name_regex,
  } do
    get '', to: 'states#show'
    get '/college-success-award', to: 'college_success_award#search', as: :college_success_awards_list
    get 'guided-search', to: redirect { |params, _|
      "/#{params[:state]}/"
    }
  end

  # Routes for school profile pages
  # This needs to go before the city routes because we want to capture the
  # ID-school_name pattern first and be looser about district names
  scope '/:state/:city/:schoolId-:school_name/', as: :school, constraints: {
      format: false,
      state: States.any_state_name_regex,
      schoolId: /\d+/,
      school_name: /[^\/]+/,
      # This city regex allows for all characters except /
      # http://guides.rubyonrails.org/routing.html#specifying-constraints
      city: /[^\/]+/,
    } do
    get "(:path)", to: "school_profiles#show"

    # e.g. POST /california/alameda/1-alameda-high-school/members to create a school_user association
    resource :user, only: [:create], controller: 'school_user', action: 'create'
  end

  # Routes for city page
  scope '/:state/:city', as: :city, constraints: {
    # Format: false allows periods to be in path segments.
    # This then needs to be paired with a regex constraint for each path component.
    # So in this hash there needs to be state and city and down below there's a constraint
    # with the district segment's constraint.
    format: false,
    state: States.any_state_name_regex,
    # This city regex allows for all characters except /
    # http://guides.rubyonrails.org/routing.html#specifying-constraints
    city: /[^\/]+/,
  } do

    get '', to: 'cities#show'
    get 'schools', to: 'error#page_not_found', as: :browse
    get 'guided-search', to: redirect { |params, _|
      "/#{params[:state]}/#{params[:city]}/"
    }, as: :guided_search

    # NOTE: this must come last in the city scope, because it will match
    # anything after the cty name
    get '/:district', to: 'districts#show', as: :district, constraints: {
      # This city regex allows for all characters except / and the word preschools
      # http://guides.rubyonrails.org/routing.html#specifying-constraints
      district: /(?!preschools)[^\/]+/
    }
  end
  # end routes for city page

  # NOTE: this must come after the city scope, because it will match anything after the city name
  # TODO: DRY this up. Or delete the above version and rename all city_district_* helpers to district_*
  get '/:state/:city/:district', to: 'districts#show', as: :district, constraints: {
      format: false,
      state: States.any_state_name_regex,
      city: /[^\/]+/,
      district: /(?!preschools)[^\/]+/
  }

  # Routes for form to add LeadGen records
  get '/ads/leadGen.page', to: 'lead_gen#show'
  post '/ads/leadGen.page', to: 'lead_gen#save'

  # Redirect routes (school profile, state, or home page)
  get '/school/overview.page', to: 'legacy_profile_redirect#show'
  get '/school/parentReviews.page', to: 'legacy_profile_redirect#show'
  get '/school/rating.page', to: 'legacy_profile_redirect#show'
  get '/school/mapSchool.page', to: 'legacy_profile_redirect#show'
  get '/school/testScores.page', to: 'legacy_profile_redirect#show'
  get '/school/teachersStudents.page', to: 'legacy_profile_redirect#show'
  get '/school/research.page', to: 'legacy_profile_redirect#show'


  # Handle preschool URLs
  scope '/:state/:city/preschools/:school_name/:schoolId/(/*other)', as: :preschool, constraints: {
      state: States.any_state_name_regex,
      schoolId: /\d+/,
      school_name: /.+/,
      # This city regex allows for all characters except /
      # http://guides.rubyonrails.org/routing.html#specifying-constraints
      city: /[^\/]+/,
  } do
    get '', to: 'school_profiles#show'
  end

  # Handle old city homepage structure
  get '/city/:city/:state_abbr(/*other)', to: 'cities_list#old_homepage', constraints: {
      city: /[^\/]+/
  }

  # Handle City SEO pages
  get '/schools/cities/:state_name/:state_abbr/', to: 'cities_list#show', as: 'cities_list'

  scope '/schools/cities/:state_name/:state_abbr/:letter', as: 'cities_list_paginated' do
    get '', to: redirect { |params, _|
      "/schools/cities/#{params[:state_name]}/#{params[:state_abbr]}/"
    }
  end

  # Handle District SEO pages
  get '/schools/districts/:state_name/:state_abbr/', to: 'districts_list#show', as: 'districts_list'

  scope '/schools/districts/:state_name/:state_abbr/:letter', as: 'districts_list_paginated' do
    get '', to: redirect { |params, _|
      "/schools/districts/#{params[:state_name]}/#{params[:state_abbr]}/"
    }
  end

  # Handle old School list SEO pages (has to come below cities_list and districts_list routes)
  get '/schools/:state_name/:state_abbr/', to: 'schools_list#show', as: :schools_list

  # error handlers
  match '/error/page_not_found' => 'error#page_not_found', :as => :page_not_found, via: [:get, :post]
  match '/error/school_not_found' => 'error#school_not_found', :as => :school_not_found, via: [:get, :post]
  match '/error/internal_error' => 'error#internal_error', :as => :internal_error, via: [:get, :post]

  # route not found catch-all
  match '*path' => 'error#page_not_found', format: false, via: [:get, :post]
end
