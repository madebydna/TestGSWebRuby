module ApplicationHelper

  def render_position(position_number)
    if @category_positions[position_number]
      category_placement = @category_positions[position_number]

      # figure out which partial to render
      partial = nil
      case category_placement.layout
        when nil
          partial = 'category_data'
        else
          partial = category_placement.layout
      end

      category = category_placement.category

      partial = "data_layouts/#{partial}"


      # TODO: refactor the old category_data partial and how data is retrieved from the category, so that
      # everything is consistent

      # TODO: handle unparsable layout_config. Maybe try to parse it upon insert, so bad data can't get in db
      if partial == 'data_layouts/category_data'
        render :partial => partial, locals: { school_category_rows: category.values_for_school(@school), category: category }
      else
        layout_config = category_placement.layout_config.gsub(/\t|\r|\n/, '').gsub(/[ ]+/i, ' ').gsub(/\\"/, '"')
        render :partial => partial,
               locals: { rows: category.data_for_school(@school), category: category, config: JSON.parse(layout_config) }
      end

    end
  end


end
