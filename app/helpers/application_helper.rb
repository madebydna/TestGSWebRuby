module ApplicationHelper

  def render_all_positions
    result = ''
    @category_positions.keys.sort.each { |position| result << (render_position position) }
    result.html_safe
  end

  def render_position(position_number)
    if @category_positions[position_number]

      placement_and_data = @category_placements[position_number]
      return if placement_and_data.nil?

      category_placement = placement_and_data[:placement]
      category = category_placement.category
      data = placement_and_data[:data]

      # different layout for debugging. triggered via url param
      if params[:category_placement_debugging] && placement_and_data
        return render 'data_layouts/category_placement_debug',
          category_placements: @category_positions[position_number],
          picked_placement: placement_and_data[:placement],
          school: @school
      end

      # mark the Category itself as picked
      mark_category_layout_picked category_placement

      # figure out which partial to render
      partial = "data_layouts/#{category_placement.layout}"

      # build json object for layout config
      if category_placement.layout_config.present?
        # TODO: handle unparsable layout_config. Maybe try to parse it upon insert, so bad data can't get in db
        layout_config = category_placement.layout_config.gsub(/\t|\r|\n/, '').gsub(/[ ]+/i, ' ').gsub(/\\"/, '"')
        layout_config_json = {}.to_json
        layout_config_json = JSON.parse(layout_config) unless layout_config.nil? || layout_config == ''
      end

      # render the category data
      render 'module_container',
        partial:partial,
        category_placement:category_placement,
        data: data,
        category: category,
        config: category_placement.layout_config.present? ? TableConfig.new(layout_config_json) : nil,
        size: category_placement.size || 12

    end
  end

  def mark_category_layout_picked(placement)
    key = placement.page_category_layout_key
    @category_layouts_already_picked_by_a_position ||= []
    @category_layouts_already_picked_by_a_position << key
  end

  def draw_stars_16(on_star_count)
    off_star_count = 5 - on_star_count
    class_on = 'iconx16-stars i-16-orange-star  i-16-star-' + on_star_count.to_s + ' fl'
    class_off = 'iconx16-stars i-16-grey-star  i-16-star-' + off_star_count.to_s + ' fl'
    content_tag(:div, '', :class => class_on)  +
        content_tag(:div, '', :class => class_off)
  end
end
