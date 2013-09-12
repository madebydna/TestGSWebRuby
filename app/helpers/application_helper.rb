module ApplicationHelper

  def render_position(position_number)
    if @category_positions[position_number]

      placement_and_data = choose_placement_and_get_data position_number

      if placement_and_data && placement_and_data[:index]
        category_placement = @category_positions[position_number][placement_and_data[:index]]
        category = category_placement.category
        data = placement_and_data[:data]

        # figure out which partial to render
        partial = "data_layouts/#{category_placement.layout}"

        # TODO: handle unparsable layout_config. Maybe try to parse it upon insert, so bad data can't get in db
        if partial == 'data_layouts/default_two_column_table'
          render partial: partial,
                 locals: {
                     data: data,
                     category: category
                 }
        else
          # cleanse the json config
          layout_config = category_placement.layout_config.gsub(/\t|\r|\n/, '').gsub(/[ ]+/i, ' ').gsub(/\\"/, '"')

          render partial: partial,
                 locals: {
                     data: data,
                     category: category,
                     config: TableConfig.new(JSON.parse(layout_config))
                 }
        end
      end

    end
  end

  def choose_placement_and_get_data(position_number)
    if @category_positions[position_number]

      category_placements = @category_positions[position_number]

      category_placements.each_with_index do | placement, index |
        data = placement.category.data_for_school(@school)

        if data.rows.any?
          return {data: data, index: index}
        else
          return nil
        end

      end

    end
  end

  # for each row in the given table_data, generate an array [key1, key2]
  def table_data_to_piechart(table_data, key1, key2)
    array = []

    table_data.rows.each do |row|
      array << [
          "#{row[key1]}", row[key2].to_i
      ]
    end

    array
  end

end
