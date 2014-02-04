LocalizedProfiles::Application.routes.draw do
  mount MochaRails::Engine => 'mocha' unless Rails.env.production?

  require 'states'
  require 'regular_subdomain'
  require 'preschool_subdomain'


  constraints(RegularSubdomain) do

    get '/join', :to => 'signin#new', :as => :signin
    match '/logout', :to => 'signin#destroy', :as => :logout

    get '/gsr/admin/help', :to => 'admin#help'

    post '/gsr/session/auth', :to => 'signin#create', :as => :authenticate_user
    match '/gsr/session/facebook_connect' => 'signin#facebook_connect', :as => :facebook_connect
    match '/gsr/session/facebook_callback' => 'signin#facebook_callback', :as => :facebook_callback
    match '/gsr/session/post_registration_confirmation' => 'signin#post_registration_confirmation', :as => :post_registration_confirmation

    post '/gsr/:state/:city/:schoolId-:school_name/reviews/create', to: 'reviews#create', as: :school_ratings, constraints: {
      state: States.any_state_name_regex,
      schoolId: /\d+/,
      school_name: /.+/
    }

    # TODO: Update this route to handle PK, like other school profile routes
    # Route for "review a school" form
    get '/gsr/:state/:city/:schoolId-:school_name/reviews/new', to: 'reviews#new', as: :new_school_rating, constraints: {
      state: States.any_state_name_regex,
      schoolId: /\d+/,
      school_name: /.+/
    }

    # TODO: Update this route to handle PK, like other school profile routes
    # Redirect /district-of-columbia school profile pages to /washington-dc
    get '/district-of-columbia/:city/:schoolId-:school_name/(/*other)', constraints: {
      state: States.any_state_name_regex,
      schoolId: /\d+/,
      school_name: /.+/
    }, to: redirect{|params, request| "/washington-dc/#{params[:city]}/#{params[:schoolId]}-#{params[:school_name]}/#{params[:other]}"}

  end

  constraints(PreschoolSubdomain) do

    # Handle preschool URLs
    scope '/:state/:city/preschools/:school_name/:schoolId/(/*other)', as: :preschool, constraints: {
        state: States.any_state_name_regex,
        schoolId: /\d+/,
        school_name: /.+/,
    } do

      get 'quality', to: 'localized_profile#quality', as: :quality
      get 'details', to: 'localized_profile#details', as: :details
      get 'reviews', to: 'localized_profile#reviews', as: :reviews
      get '', to: 'localized_profile#overview'
    end

  end

  constraints(RegularSubdomain) do

    # Routes for school profile pages
    scope '/:state/:city/:schoolId-:school_name', as: :school, constraints: {
        state: States.any_state_name_regex,
        schoolId: /\d+/,
        school_name: /.+/,
    } do
      get 'quality', to: 'localized_profile#quality', as: :quality
      get 'details', to: 'localized_profile#details', as: :details
      get 'reviews', to: 'localized_profile#reviews', as: :reviews
      get '', to: 'localized_profile#overview'
    end

    # Notice that this scope doesnt have the subdomain constraint. Preschool requests missing pk subdomain will fall
    # through and be handled by this route scope
    get '/:state/:city/preschools/:school_name/:schoolId/(/*other)', constraints: {
      state: States.any_state_name_regex,
      schoolId: /\d+/,
      school_name: /.+/,
    }, to: redirect(PreschoolSubdomain.method(:current_url_on_pk_subdomain))

    get '/gsr/admin/omniture-test', to: 'admin#omniture_test', as: :omniture_test

    get '/gsr/ajax/reviews_pagination', :to => 'localized_profile_ajax#reviews_pagination'

    # Route to handle ajax "email available" validation
    get '/gsr/validations/email_available', :to => 'user#email_available'

    resources :subscriptions, except: [:destroy, :delete, :index], path: '/gsr/user/subscriptions'
    resources :favorite_schools, except: [:destroy, :delete, :index], path: '/gsr/user/favorites'

    scope '/gsr' do
      devise_for :admins
    end

    mount RailsAdmin::Engine => '/gsr/admin', :as => 'rails_admin'

    # error handlers
    match '/error/page_not_found' => 'error#page_not_found', :as => :page_not_found
    match '/error/school_not_found' => 'error#school_not_found', :as => :school_not_found
    match '/error/internal_error' => 'error#internal_error', :as => :internal_error

    # this route only affects local development environments right now, since tomcat will handle this URL,
    # and execute existing java code
    get '/community/registrationConfirm.page' => redirect('/community/registrationConfirm.page', port: 8080), as: :verify_email

  end

  constraints(PreschoolSubdomain) do

    # If a url is on pk subdomain and matches no other routes, remove the pk subdomain and redirect
    match '*path', to: redirect(PreschoolSubdomain.method(:current_url_without_pk_subdomain))

  end

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
