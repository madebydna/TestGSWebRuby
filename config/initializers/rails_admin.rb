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
  # config.audit_with :paper_trail, 'Admin' # removing since it's causing error
  # require 'paper_trail'
  # config.audit_with :paper_trail, 'Admin'

  # Display empty fields in show views:
  # config.compact_show_view = false

  # Number of default rows per-page:
  # config.default_items_per_page = 20

  # Exclude specific models (keep the others):
  # config.excluded_models = ['Category', 'CategoryPlacement', 'Collection', 'Page', 'School', 'EspResponse', 'SchoolCollection', 'User']

  # Include specific models (exclude the others):
  config.included_models = [
    'Category',
    'CategoryData',
    'CategoryPlacement',
    'ResponseValue',
    'SchoolProfileConfiguration'
  ]

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


  ###  CategoryData  ###

  config.model 'CategoryData' do
    label 'Module data points'
    list do
      filters [:category]
      field :category do
        label 'Module'
      end
      field :rails_admin_category_data_key, :enum do
        label 'Data point'
        enum_method do
          :rails_admin_response_keys
        end
      end
      field :label
      field :collection do
        def value
          v = super
          v.name unless v.nil?
        end
      end
      field :sort_order
      field :updated_at
    end

    edit do
      field :category
      field :rails_admin_category_data_key, :enum do
        label 'Data point'
        enum_method do
          :rails_admin_response_keys
        end
      end
      field :rails_admin_category_data_key_freeform
      field :label
      field :sort_order
      field :source, :enum do
        enum_method do
          :possible_sources
        end
      end
      field :collection_id, :enum do
        enum do
          Collection.all.map { |collection| [collection.name, collection.id] }
        end
      end
      field :json_config, :text do
        def value
          data = super
          JSON.pretty_unparse(JSON.parse(data)) if data.present?
        end
        codemirror true
      end
    end
  end

  ###  Category  ###

  config.model 'Category' do
    label 'Module'

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
          # field :parent
          field :name
          field :description
          field :source
          field :updated_at
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
       #end
  #     show do; end
      edit do
        # field :parent
        field :name
        field :source, :enum do
          enum_method do
            :possible_sources
          end
        end
        field :description
      end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  end


###  CategoryPlacement  ###

  config.model 'CategoryPlacement' do
    label 'Page module'
    nestable_tree({
      position_field: :position,
      max_depth: 3,
      scope: :page,
    })

    list do
      items_per_page 500
      filters [:page]
      field :page
      field :title
      field :collection do
        def value
          v = super
          v.name unless v.nil?
        end
      end
      field :category do
        label 'Module'
      end
      field :layout do
        label 'Template'
      end
    end

    edit do
      field :title
      field :category do
        label 'Module'
      end
      field :page
      field :collection_id, :enum do
        enum do
          Collection.all.map { |collection| [collection.name, collection.id] }
        end
      end
      field :layout, :enum do
        enum_method do
          :possible_layouts
        end
      end
      field :layout_config, :text do
        def value
          data = super
          JSON.pretty_unparse(JSON.parse(data)) if data.present?
        end
        codemirror true
      end
      field :ancestry, :enum do
        enum do
          except = bindings[:object].id
          CategoryPlacement.where("id != ?", except).map { |c| [ c.title, c.id ] }
        end
      end
    end
 end

  ###  Page  ###
  # config.model 'Page' do
  #   list do
  #     field :name
  #     field :parent
  #     field :updated_at
  #   end
  #   edit do
  #     field :name
  #     field :parent
  #     field :updated_at
  #   end
  # end

  ###  CategoryData  ###

  config.model 'ResponseValue' do
    label 'Response labels'
    list do
      field :response_key
      field :response_value
      field :response_label
      field :collection do
        def value
          v = super
          v.name unless v.nil?
        end
      end
      field :updated_at
    end

    edit do
      field :response_key
      field :response_value
      field :response_label
      field :collection_id, :enum do
        enum do
          Collection.all.map { |collection| [collection.name, collection.id] }
        end
      end
    end
  end

  ###  SchoolProfileConfiguration  ###

  config.model 'SchoolProfileConfiguration' do

    list do
      field :state
      field :configuration_key
      field :value
    end
    edit do
      field :state
      field :configuration_key
      field :value, :text do
        def value
          data = super
          JSON.pretty_unparse(JSON.parse(data)) if data.present?
        end
        codemirror true
      end
    end
  end

  config.actions do
    all
    undo
    nestable
  end
end
