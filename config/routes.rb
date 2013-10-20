LocalizedProfiles::Application.routes.draw do
  require 'states'
  resources :census_data_sets

  get '/:state/:city/:schoolId-:school_name/reviews', to: 'localized_profile#reviews', constraints: {
    state: States.any_state_name_regex,
    schoolId: /\d+/,
    school_name: /.+/
  }
  # Handle existing school profile links. Point them to overview action
  get '/:state/:city/:schoolId-:school_name', to: 'localized_profile#overview', constraints: {
      state: States.any_state_name_regex,
      schoolId: /\d+/,
      school_name: /.+/
  }

  get '/profile/overview', :to => 'localized_profile#overview'
  get '/profile/quality', :to => 'localized_profile#quality'
  get '/profile/details', :to => 'localized_profile#details'
  get '/profile/reviews', :to => 'localized_profile#reviews'
  get '/profile/testscores', :to=> 'localized_profile#test_scores'
  get '/ajax/reviews_pagination', :to => 'localized_profile_ajax#reviews_pagination'

  devise_for :admins

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'


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
