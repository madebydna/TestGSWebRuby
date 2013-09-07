module ApplicationHelper

  def render_position(position_number)
    if @category_positions[position_number]
      category_placement = @category_positions[position_number]

      # figure out which partial to render
      partial = nil
      case category_placement.layout
        when nil
          partial = 'default_two_column_table'
        else
          partial = category_placement.layout
      end

      category = category_placement.category

      partial = "data_layouts/#{partial}"

      table_data = category.data_for_school(@school)

      # TODO: handle unparsable layout_config. Maybe try to parse it upon insert, so bad data can't get in db
      if partial == 'data_layouts/default_two_column_table'
        render partial: partial,
               locals: {
                   data: table_data,
                   category: category
               }
      else
        # cleanse the json config
        layout_config = category_placement.layout_config.gsub(/\t|\r|\n/, '').gsub(/[ ]+/i, ' ').gsub(/\\"/, '"')

        render partial: partial,
               locals: {
                   data: table_data,
                   category: category,
                   config: TableConfig.new(JSON.parse(layout_config))
               }
      end

    end
  end


end
