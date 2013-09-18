# RailsAdmin config file. Generated on August 20, 2013 16:37
# See github.com/sferik/rails_admin for more informations

require Rails.root.join('lib', 'rails_admin_undo_action.rb')
RailsAdmin.config do |config|

  ################  Global configuration  ################

  # Set the admin name here (optional second array element will appear in red). For example:
  config.main_app_name = ['Localized Profiles', 'Admin']
  # or for a more dynamic name:
  # config.main_app_name = Proc.new { |controller| [Rails.application.engine_name.titleize, controller.params['action'].titleize] }

  # RailsAdmin may need a way to know who the current user is]
  config.current_user_method { current_admin } # auto-generated

  # If you want to track changes on your models:
  # config.audit_with :history, 'User'

  # Or with a PaperTrail: (you need to install it first)
  config.audit_with :paper_trail, 'Admin'

  # Display empty fields in show views:
  # config.compact_show_view = false

  # Number of default rows per-page:
  # config.default_items_per_page = 20

  # Exclude specific models (keep the others):
  # config.excluded_models = ['Category', 'CategoryPlacement', 'Collection', 'Page', 'School', 'EspResponse', 'SchoolCollection', 'User']

  # Include specific models (exclude the others):
  config.included_models = ['Category', 'CategoryData', 'CategoryPlacement', 'Collection', 'Page', 'School', 'SchoolCollection', 'ResponseValue']

  # Label methods for model instances:
  # config.label_methods << :description # Default is [:name, :title]


  ################  Model configuration  ################

  # Each model configuration can alternatively:
  #   - stay here in a `config.model 'ModelName' do ... end` block
  #   - go in the model definition file in a `rails_admin do ... end` block

  # This is your choice to make:
  #   - This initializer is loaded once at startup (modifications will show up when restarting the application) but all RailsAdmin configuration would stay in one place.
  #   - Models are reloaded at each request in development mode (when modified), which may smooth your RailsAdmin development workflow.


  # Now you probably need to tour the wiki a bit: https://github.com/sferik/rails_admin/wiki
  # Anyway, here is how RailsAdmin saw your application's models when you ran the initializer:



  ###  Category  ###

  config.model 'Category' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your category.rb model definition

  #   # Found associations:

  #     configure :parent, :belongs_to_association
  #     configure :category_placements, :has_many_association 
  #     configure :categories, :has_many_association

  #   # Found columns:

  #     configure :id, :integer 
  #     configure :parent_id, :integer         # Hidden
  #     configure :name, :string
  #     configure :description, :string
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

       #list do
          field :parent
          field :name
          field :description
          field :updated_at
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
       #end
  #     show do; end
      edit do
        field :parent
        field :name
        field :source
        field :description
        field :updated_at
      end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  end


###  CategoryPlacement  ###

 config.model 'CategoryPlacement' do

   # You can copy this to a 'rails_admin do ... end' block inside your category_placement.rb model definition

   # Found associations:

   #  configure :category, :belongs_to_association
   #  configure :collection, :belongs_to_association
   #  configure :page, :belongs_to_association

   # Found columns:

   #  configure :id, :integer
   #  configure :category_id, :integer         # Hidden
   #  configure :collection_id, :integer         # Hidden
   #  configure :page_id, :integer         # Hidden
   #  configure :position, :integer
   #  configure :created_at, :datetime
   #  configure :updated_at, :datetime

   # Cross-section configuration:

     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
     # label_plural 'My models'      # Same, plural
     # weight 0                      # Navigation priority. Bigger is higher.
     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

   # Section specific configuration:

   #  list do
       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
       # items_per_page 100    # Override default_items_per_page
       # sort_by :id           # Sort column (default is primary key)
       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
   #  end
   #  show do; end
   #  edit do; end
   #  export do; end

   list do
     field :page
     field :title
     field :position
     field :size, :enum do
       enum_method do
         :possible_sizes
       end
     end
     #field :priority
     field :collection
     field :category
     field :layout, :enum do
       enum_method do
         :possible_layouts
       end
     end
   end

   edit do
     field :title
     #field :priority
     field :category
     field :page
     field :position
     field :size, :enum do
       enum_method do
         :possible_sizes
       end
     end
     field :collection
     field :layout, :enum do
       enum_method do
         :possible_layouts
       end
     end
     field :layout_config, :text do
       codemirror true
     end
   end
     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
     # using `field` instead of `configure` will exclude all other fields and force the ordering
 end


  ###  Collection  ###

   config.model 'Collection' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your collection.rb model definition

  #   # Found associations:

  #     configure :school_collections, :has_many_association 
  #     configure :schools, :has_many_association 

  #   # Found columns:

  #     configure :id, :integer 
  #     configure :name, :string 
  #     configure :description, :string 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

       list do
         field :name
         field :description
         field :updated_at
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
       end
  #     show do; end
      edit do
        field :name
        field :description
        field :updated_at
      end

  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  end


  ###  Page  ###

  config.model 'Page' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your page.rb model definition

  #   # Found associations:

  #     configure :parent, :belongs_to_association 
  #     configure :category_placements, :has_many_association 
  #     configure :pages, :has_many_association 

  #   # Found columns:

  #     configure :id, :integer 
  #     configure :name, :string 
  #     configure :parent_id, :string         # Hidden 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

       list do
         field :name
         field :parent
         field :updated_at
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
       end
  #     show do; end
        edit do
          field :name
          field :parent
          field :updated_at
        end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  end


  ###  School  ###

  # config.model 'School' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your school.rb model definition

  #   # Found associations:

  #     configure :school_collections, :has_many_association 
  #     configure :collections, :has_many_association 
  #     configure :esp_responses, :has_many_association 

  #   # Found columns:

  #     configure :id, :integer 
  #     configure :state, :string 
  #     configure :name, :string 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  EspResponse  ###

  # config.model 'EspResponse' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your esp_response.rb model definition

  #   # Found associations:

  #     configure :school, :belongs_to_association 
  #     configure :category, :belongs_to_association 

  #   # Found columns:

  #     configure :id, :integer 
  #     configure :school_id, :integer         # Hidden 
  #     configure :category_id, :integer         # Hidden 
  #     configure :key, :string 
  #     configure :value, :string 
  #     configure :value_type, :string 
  #     configure :active, :boolean 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  SchoolCollection  ###

   config.model 'SchoolCollection' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your school_collection.rb model definition

  #   # Found associations:

  #     configure :school, :belongs_to_association 
  #     configure :collection, :belongs_to_association 

  #   # Found columns:

  #     configure :id, :integer 
  #     configure :school_id, :integer         # Hidden 
  #     configure :collection_id, :integer         # Hidden 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

       list do
         field :collection
         field :school
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
       end

       edit do
         field :state, :enum do
           enum_method do
             :state_hash
           end
           partial 'state_select'
         end
         field :collection
         field :school do
           associated_collection_cache_all false  # REQUIRED if you want to SORT the list as below
           associated_collection_scope do
             # bindings[:object] & bindings[:controller] are available, but not in scope's block!
             params = bindings[:controller].params
             state = params[:state] || 'CA'

             Proc.new { |scope|
               # scoping all Players currently, let's limit them to the team's league
               # Be sure to limit if there are a lot of Players and order them by position
               #scope = scope.using(state.upcase.to_sym)
               scope = scope.using(state.upcase.to_sym)
             }
           end
         end
       end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
   end


  ###  User  ###

  # config.model 'User' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your user.rb model definition

  #   # Found associations:



  #   # Found columns:

  #     configure :id, :integer 
  #     configure :email, :string 
  #     configure :password, :password         # Hidden 
  #     configure :password_confirmation, :password         # Hidden 
  #     configure :reset_password_token, :string         # Hidden 
  #     configure :reset_password_sent_at, :datetime 
  #     configure :remember_created_at, :datetime 
  #     configure :sign_in_count, :integer 
  #     configure :current_sign_in_at, :datetime 
  #     configure :last_sign_in_at, :datetime 
  #     configure :current_sign_in_ip, :string 
  #     configure :last_sign_in_ip, :string 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end

  config.actions do
    all
    undo
  end
end
