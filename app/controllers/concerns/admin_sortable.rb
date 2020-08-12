module AdminSortable
  extend ActiveSupport::Concern

  included do
    helper_method :sort_column, :sort_direction, :sort_options
  end

  def sort_column
    sort_options.fetch(params[:sort], sort_options["default"])
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : default_direction
  end

  def sort_options
    get_current_controller::SORT_OPTIONS
  end

  def default_direction
    get_current_controller::DEFAULT_DIRECTION
  end

  def get_current_controller
    "Admin::#{controller_name.classify.pluralize}Controller".constantize
  end
end