class CategoryPlacementPresenter

  attr_reader :category_placement

  VIEW_DIRECTORY = Rails.root.join('app', 'views')
  DATA_LAYOUTS_DIRECTORY = 'school_profile/data_layouts'

  def initialize(category_placement, page_config, template)
    @category_placement = category_placement
    @page_config = page_config
    @template = template
  end

  def title
    @category_placement.title
  end

  def layout
    @category_placement.layout
  end

  def h
    @template
  end

  def render
    partial_wrapper = self.partial_wrapper

    partial_params = {
      category_placement: category_placement,
      data: h.category_placement_data(@page_config, category_placement),
      category: category_placement.category
    }

    if partial_wrapper
      h.render(layout: partial_wrapper, locals: partial_params) do
        h.render(default_partial, partial_params)
      end
    else
      h.render(default_partial, partial_params)
    end
  end

  def partial
    partial_wrapper || default_partial
  end

  def partial_wrapper
    page_specific_partial || module_specific_partial
  end

  def page_specific_partial
    page_specific_layout = "#{h.params[:controller]}/#{wrapper_layout}"
    page_specific_file =
      File.join(
        VIEW_DIRECTORY,
        h.params[:controller],
        "_#{wrapper_layout}.html.erb"
      )

    return page_specific_layout if File.exist?(page_specific_file)
  end

  def module_specific_partial
    module_specific_layout = "#{DATA_LAYOUTS_DIRECTORY}/#{wrapper_layout}"
    module_specific_file =
      File.join(
        VIEW_DIRECTORY,
        DATA_LAYOUTS_DIRECTORY,
        "_#{wrapper_layout}.html.erb"
      )

    return module_specific_layout if File.exist?(module_specific_file)
  end

  def wrapper_layout
    "#{title.downcase}_#{layout}" if title.present?
  end

  def default_partial
    File.join(DATA_LAYOUTS_DIRECTORY, layout)
  end

  def show_bottom_ads?
    @category_placement.layout_config_json['show_bottom_ads'] == true
  end
end
