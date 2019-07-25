module ReviewHelper

  def create_sort_link(sort_field, label = nil)
    label ||= sort_field.titleize
    direction = (Admin::ReviewsController::SORT_OPTIONS[sort_field] == sort_column && sort_direction == "asc") ? "desc" : "asc"

    link_to label, :sort => sort_field, :direction => direction
  end
end