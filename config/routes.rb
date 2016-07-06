
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

  # change to /reviews/?topic=1
  get '/reviews/', as: :review_choose_school, to: 'review_school_chooser#show'
  get '/morgan-stanley/', as: :morgan_stanley, to: 'review_school_chooser#morgan_stanley'


  #get '/gsr/pyoc', to: 'pyoc#print_pdf' , as: :print_pdf

  # Routes for search pages
  get ':state/:city/schools/', as: :search_city_browse,
    # This city regex allows for all characters except /
    # http://guides.rubyonrails.org/routing.html#specifying-constraints
    constraints: {state: States.any_state_name_regex, city: /[^\/]+/}, to: 'search#city_browse'

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

  get ':state/:city/:district_name/schools/', as: :search_district_browse,
    # This city regex allows for all characters except /
    # http://guides.rubyonrails.org/routing.html#specifying-constraints
    constraints: {state: States.any_state_name_regex, city: /[^\/]+/, district_name: /[^\/]+/}, to: 'search#district_browse'

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

  get '/search/search.page', as: :search, to: 'search#search'

  get '/find-schools/', as: :default_search, to: 'search#default_search'


  resources :user_preferences, only: [:edit]

  get '/preferences/' => 'user_email_preferences#show', as: 'user_preferences'
  post '/preferences/' => 'user_email_preferences#update', as: 'user_preferences_update'

  post '/unsubscribe/' => 'user_email_unsubscribes#create', as: 'user_email_unsubscribes'
  get '/unsubscribe/' => 'user_email_unsubscribes#new', as: 'unsubscribe'

  resources :saved_searches, only: [:create, :destroy], path: '/gsr/ajax/saved_search'

  get '/compare', as: :compare_schools, to: 'compare_schools#show'
  get '/community/', to: 'community_landing#show',as: :community_landing

  get  '/school/esp/form.page', to: 'osp#show' , as: :osp_page
  get '/official-school-profile/', to: 'osp_landing#show',as: :osp_landing
  match '/official-school-profile/register.page', to: 'osp_registration#new', as: :osp_registration, via: [:get]
  match '/official-school-profile/register.page', to: 'osp_registration#submit',as: :osp_registration_submit, via: [:post]

   get '/official-school-profile/registration-confirmation', to: 'osp_confirmation#show',as: :osp_confirmation

  post  '/school/esp/submit_form.page', to: 'osp#submit' , as: :osp_submit
  post  '/gsr/ajax/esp/add_image', to: 'osp#add_image' , as: :osp_add_image
  delete  '/gsr/ajax/esp/delete_image', to: 'osp#delete_image' , as: :osp_delete_image

  get '/gsr/search/suggest/school', as: :search_school_suggest, to: 'search#suggest_school_by_name'
  get '/gsr/search/suggest/city', as: :search_city_suggest, to: 'search#suggest_city_by_name'
  get '/gsr/search/suggest/district', as: :search_district_suggest, to: 'search#suggest_district_by_name'
  get '/gsr/ajax/search/calculate_fit', as: :search_calculate_fit, to: 'search_ajax#calculate_school_fit'
  get '/gsr/user/account_subscriptions', to: 'subscriptions#create_subscription_from_account_page', as: 'create_subscription_from_account_page'
  get '/gsr/ajax/community-scorecard/get-school-data', to: 'community_scorecards_ajax#get_school_data'
  get '/gsr/footer', to: 'footer#show'

  # todo delete this when java is gone
  get '/approve_provisional_osp_user_data', as: :approve_provisional_osp_user_data, to: 'approve_provisional_osp_user_data#approve_provisional_osp_user_data'

# Routes within this scope are pages not handled by Rails.
  # They are included here so that we can take advantage of the helpful route url helpers, e.g. home_path or jobs_url
  # We need to assign the route a controller action, so just point to page_not_found
  scope '', controller: 'error', action: 'page_not_found' do
    get '/gk/', as: :greatkids_home
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
    get '/gk/back-to-school/', as: :back_to_school
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
    get '/official-school-profile/register.page?city=:city&schoolId=:school_id&state=:state', as: :osp_register
    get '/school/QandA/form.page?schoolId=:school_id&state=:state', as: :osp_form
    get '/official-school-profile/dashboard/', as: :osp_dashboard
    get '/gk/videos/choose-elementary-school-video/', as: :help_me_e_video
    get '/gk/videos/choose-middle-school-video/', as: :help_me_m_video
    get '/gk/videos/choose-high-school-video/', as: :help_me_h_video
    get '/catalog/pdf/SpringSweepsRules.pdf', as: :sweepstakes_rules
    get '/understanding-common-core-state-standards.topic?content=7802', as: :common_core
    get '/healthy-kids.topic?content=2504', as: :health_and_wellness_article
    get '/gk/road-to-college/', as: :college_articles
    get '/STEM.topic?content=8021', as: :stem_article
    get '/schools/cities/:state_long/:state_short/:letter', as: :city_alphabet
    get '/schools/cities/:state_long/:state_short', as: :city_list
    get '/schools/districts/:state_long/:state_short', as: :district_list
    get '/school-district-boundaries-map/', as: :district_boundary
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
    get '/gk/partners', as: :gk_partners
    get '/gk/licensing', as: :gk_licensing
    get '/gk/sponsorship', as: :sponsorship
    get '/gk/advertising', as: :advertising
    get '/gk/careers', as: :careers
    get '/gk/funders', as: :funders
    get '/gk/about', as: :about
    get '/status/error404.page'
  end

  namespace :admin, controller: 'admin', path: '/admin/gsr' do
    get '/omniture-test', to: :omniture_test, as: :omniture_test
    get '/info', to: :info
    get '/examples-and-gotchas', to: :examples_and_gotchas

    scope '/school-profiles', as: :school_profiles do
      get '/help', to: 'admin#help'
      mount RailsAdmin::Engine => '', :as => 'rails_admin'
    end

    get '/style-guide/', to: 'style_guide#index'
    get '/style-guide/:category/:page', to: 'style_guide#render_page'
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

    resources :held_school
    resources :reported_entity do
      put 'deactivate', on: :member
    end

    resources :data_load_schedules, path: '/data-planning'
  end
  post '/gsr/ajax/wordpress_submit', to: 'wordpress_interface#call_from_wordpress', as: :call_from_wordpress
  post '/gsr/reviews/:id/flag', to: 'reviews#flag', as: :flag_review
  post '/gsr/reviews/:id/vote', :to => 'review_votes#create'
  post '/gsr/reviews/:id/unvote', :to => 'review_votes#destroy'
  get '/gsr/ajax/reviews_pagination', :to => 'localized_profile_ajax#reviews_pagination'
  get '/gsr/ajax/get_cities', :to => 'simple_ajax#get_cities'
  get '/gsr/ajax/get_schools', :to => 'simple_ajax#get_schools'
  get '/gsr/ajax/get_school_and_forward', to: 'simple_ajax#get_school_and_forward', as: :get_school_and_forward
  get '/gsr/validations/validate_user_can_log_in', :to => 'user#validate_user_can_log_in'
  get '/gsr/user/send_verification_email', :to => 'user#send_verification_email'
  # Route to handle ajax "email available" validation
  get '/gsr/validations/email_available', :to => 'user#email_available'
  get '/gsr/validations/need_to_signin', :to => 'user#need_to_signin'
  get '/gsr/user/save_city_state', :to => 'user#update_user_city_state'
  get '/gsr/user/save_grade_selection', :to => 'user#update_user_grade_selection'
  get '/gsr/user/delete_grade_selection', :to => 'user#delete_user_grade_selection'

  resources :subscriptions, except: [:index], path: '/gsr/user/subscriptions'
  get '/gsr/user/subscriptions', to: 'subscriptions#subscription_from_link', as: 'create_subscription_from_link'
  resources :favorite_schools, except: [:index], path: '/gsr/user/favorites'

  get '/gsr/modals/signup_and_follow_school_modal',:to=> 'modals#signup_and_follow_school_modal', as: :signup_and_follow_school_modal
  get '/gsr/modals/:modal', to: 'modals#show', as: :modal

  post '/gsr/session/auth', :to => 'signin#create', :as => :authenticate_user
  match '/gsr/session/register_email', to: 'signin#register_email_unless_exists', :as => :register_email, via: [:post]
  match '/logout', :to => 'signin#destroy', :as => :logout, via: [:get, :post, :delete]
  match '/gsr/session/facebook_connect' => 'signin#facebook_connect', :as => :facebook_connect, via: [:get, :post]
  match '/gsr/session/facebook_callback' => 'signin#facebook_callback', :as => :facebook_callback, via: [:get, :post]
  match '/gsr/session/facebook_auth' => 'signin#facebook_auth', :as => :facebook_auth, via: [:get, :post]
  match '/gsr/session/post_registration_confirmation' => 'signin#post_registration_confirmation', :as => :post_registration_confirmation, via: [:get, :post]
  # This route needs to be either merged with authenticate_token, or renamed to be more consistent with that one
  # JIRA: JT-385
  get '/gsr/user/verify', as: :verify_email, to: 'signin#verify_email'

  # post '/gsr/:state/:city/:schoolId-:school_name/reviews/create', to: 'reviews#create', as: :school_ratings, constraints: {
  #     state: States.any_state_name_regex,
  #     schoolId: /\d+/,
  #     school_name: /.+/
  # }

  # Passwords:

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
  put '/account/password', to: 'password#update', as: :password
  # When this route is requested, we should deliver a page with a form that allows the user to type in and confirm
  # a new password. The user must be logged in before they can see this form
  get '/account/password', to: 'password#show'


  scope '/community/:collection_id-:collection_name',
    as: :community,
    constraints: {
      collection_id: /\d+/,
      collection_name: /.+/,
    } do
      get 'spotlight', to: 'community_spotlights#show', as: :spotlight
      get '', to: 'community#home', as: :home
    end

  constraints(RegularSubdomain) do
    get '/join', :to => 'signin#new_join', :as => :join
    get '/gsr/login', :to => 'signin#new', :as => :signin

    scope '/:state', as: :state, constraints: {
        state: States.any_state_name_regex,
    } do
      get '', to: 'states#show'
      get 'browse', to: 'states#foobar', as: :browse
      get 'choosing-schools', to: 'states#choosing_schools', as: :choosing_schools
      get 'guided-search', to: 'guided_search#show', as: :guided_search
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

    # Routes for school profile pages
    # This needs to go before the city routes because we want to capture the
    # ID-school_name pattern first and be looser about district names
    scope '/:state/:city/:schoolId-:school_name', as: :school, constraints: {
        format: false,
        state: States.any_state_name_regex,
        schoolId: /\d+/,
        school_name: /.+/,
        # This city regex allows for all characters except /
        # http://guides.rubyonrails.org/routing.html#specifying-constraints
        city: /[^\/]+/,
    } do
      get 'quality', to: 'school_profile_quality#quality', as: :quality
      get 'details', to: 'school_profile_details#details', as: :details
      # TODO: The reviews index action should use method on controller called 'index' rather than 'reviews'
      resources :reviews, only: [:index], controller: 'school_profile_reviews', action: 'reviews'
      resources :reviews, only: [:create], controller: 'school_profile_reviews'
      # e.g. POST /california/alameda/1-alameda-high-school/members to create a school_user association
      resource :user, only: [:create], controller: 'school_user', action: 'create'
      get '', to: 'school_profile_overview#overview'
    end

    # Routes for city page
    scope '/:state/:city', as: :city, constraints: {
      # Format: false allows periods to be in path segments.
      # This then needs to be paired with a regex constraint for each path component.
      # So in this hash there needs to be state and city and down below there's a constraint 
      # with the district segment's contrainst.
      format: false,
      state: States.any_state_name_regex,
      # This city regex allows for all characters except /
      # http://guides.rubyonrails.org/routing.html#specifying-constraints
      city: /[^\/]+/,
    } do

      get '', to: 'cities#show'
      get 'events', to: 'cities#events', as: :events
      get 'choosing-schools', to: 'cities#choosing_schools', as: :choosing_schools
      get 'enrollment', to: 'cities#enrollment', as: :enrollment
      get 'schools', to: 'error#page_not_found', as: :browse
      get 'guided-search', to: 'guided_search#show', as: :guided_search

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

      # NOTE: this must come last in the city scope, because it will match
      # anything after the cty name
      get '/:district', to: 'districts#show', as: :district, constraints: {
        # This city regex allows for all characters except / and the word preschools
        # http://guides.rubyonrails.org/routing.html#specifying-constraints
        district: /(?!preschools)[^\/]+/
      }
    end

    # NOTE: this must come after the city scope, because it will match anything after the city name
    # TODO: DRY this up. Or delete the above version and rename all city_district_* helpers to district_*
    get '/:state/:city/:district', to: 'districts#show', as: :district, constraints: {
        format: false,
        state: States.any_state_name_regex,
        city: /[^\/]+/,
        district: /(?!preschools)[^\/]+/
    }

    # Handle legacy school overview URL. Will cause a 301 redirect. Another redirect (302) will occur since the URL we're redirecting to isn't the canonical URL
    get '/school/overview.page', to: redirect { |params, request|
          if request && request.query_parameters.present? && request.query_parameters[:state] && request.query_parameters[:id]
            "/#{States.state_name(request.query_parameters[:state])}/city/#{request.query_parameters[:id]}-school-name/"
          else
            '/status/error404.page'
          end
        }
  end

  # Handle preschool URLs
  scope '/:state/:city/preschools/:school_name/:schoolId/(/*other)', as: :preschool, constraints: {
      state: States.any_state_name_regex,
      schoolId: /\d+/,
      school_name: /.+/,
      # This city regex allows for all characters except /
      # http://guides.rubyonrails.org/routing.html#specifying-constraints
      city: /[^\/]+/,
  } do

    get 'quality', to: 'school_profile_quality#quality', as: :quality
    get 'details', to: 'school_profile_details#details', as: :details
    resources :reviews, only: [:index], controller: 'school_profile_reviews', action: 'reviews'
    resources :reviews, only: [:create], controller: 'school_profile_reviews'
    resource :user, only: [:create], controller: 'school_user', action: 'create'
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
