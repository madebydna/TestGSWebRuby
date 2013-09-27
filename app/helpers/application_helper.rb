module ApplicationHelper

  def render_position(position_number)
    if @category_positions[position_number]

      placement_and_data = @category_placements[position_number]
      #choose_placement_and_get_data position_number

      if params[:category_placement_debugging] && placement_and_data
        return render 'data_layouts/category_placement_debug',
          category_placements: @category_positions[position_number],
          picked_placement: placement_and_data[:placement],
          school: @school
      end

      if placement_and_data && placement_and_data[:placement]
        category_placement = placement_and_data[:placement]
        category = category_placement.category
        data = placement_and_data[:data]

        # mark the Category itself as picked
        mark_category_layout_picked category_placement

        # figure out which partial to render
        partial = "data_layouts/#{category_placement.layout}"

        # TODO: handle unparsable layout_config. Maybe try to parse it upon insert, so bad data can't get in db
        if partial == 'data_layouts/default_two_column_table'
          render 'module_container',
            partial: partial,
            category_placement: category_placement,
            data: data,
            category: category,
            size: category_placement.size
        else
          # cleanse the json config
          layout_config = category_placement.layout_config.gsub(/\t|\r|\n/, '').gsub(/[ ]+/i, ' ').gsub(/\\"/, '"')

          layout_config_json = {}.to_json
          layout_config_json = JSON.parse(layout_config) unless layout_config.nil? || layout_config == ''

          render 'module_container',
             partial:partial,
             category_placement:category_placement,
             data: data,
             category: category,
             config: TableConfig.new(layout_config_json),
             size:category_placement.size || 12
        end
      end

    end
  end

  def page_category_layout_key(placement)
    "page#{placement.page.id}_category#{placement.category.id}_layout#{placement.layout}"
  end

  def mark_category_layout_picked(placement)
    key = page_category_layout_key placement
    @category_layouts_already_picked_by_a_position ||= []
    @category_layouts_already_picked_by_a_position << key
  end




  def state_hash
    States::state_hash
  end

end
