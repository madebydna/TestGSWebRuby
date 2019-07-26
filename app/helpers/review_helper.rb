module ReviewHelper

  def create_sort_link(sort_field, label = nil)
    label ||= sort_field.titleize
    direction = (Admin::ReviewsController::SORT_OPTIONS[sort_field] == sort_column && sort_direction == "asc") ? "desc" : "asc"
    css_class = (Admin::ReviewsController::SORT_OPTIONS[sort_field] == sort_column) ? "active-sort" : nil
    
    if (Admin::ReviewsController::SORT_OPTIONS[sort_field] == sort_column && sort_direction == "asc")
      arrow_icon = 'icon-caret-down'
    elsif (Admin::ReviewsController::SORT_OPTIONS[sort_field] == sort_column && sort_direction == "desc")
      arrow_icon = 'icon-caret-down rotate-text-180'
    else
      arrow_icon = 'icon-caret-down rotate-text-270'
    end 

    link_to "#{label} <span class='#{arrow_icon}' />".html_safe, {:sort => sort_field, :direction => direction}, :class => css_class
  end
end