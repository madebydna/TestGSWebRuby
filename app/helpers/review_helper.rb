module ReviewHelper

  def create_sort_link(sort_field, label = nil)
    label ||= sort_field.titleize
    current_sort_field = sort_options.fetch(sort_field, '')
    direction = (current_sort_field == sort_column && sort_direction == "asc") ? "desc" : "asc"
    css_class = (current_sort_field == sort_column) ? "active-sort" : nil

    if (current_sort_field == sort_column && sort_direction == "asc")
      arrow_icon = 'icon-caret-down'
    elsif (current_sort_field == sort_column && sort_direction == "desc")
      arrow_icon = 'icon-caret-down rotate-text-180'
    else
      arrow_icon = 'icon-caret-down rotate-text-270'
    end

    link_to "#{label} <span class='#{arrow_icon}' />".html_safe, {:sort => sort_field, :direction => direction}, :class => css_class
  end

  def active_sort_cell(sort_field)
    current_sort_field = sort_options.fetch(sort_field, '')
    if current_sort_field == sort_column
      return 'active-sort-cell'
    end
    nil
  end
end