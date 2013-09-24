module ApplicationHelper

  def render_position(position_number)
    if @category_positions[position_number]

      placement_and_data = choose_placement_and_get_data position_number

      if params[:category_placement_debugging] && placement_and_data
        return render 'data_layouts/category_placement_debug',
          position_number: position_number,
          picked_placement: placement_and_data[:placement]
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
  def category_layout_already_picked?(placement)
    @category_layouts_already_picked_by_a_position ||= []
    key = page_category_layout_key placement
    @category_layouts_already_picked_by_a_position.include? key
  end
  def mark_category_layout_picked(placement)
    key = page_category_layout_key placement
    @category_layouts_already_picked_by_a_position ||= []
    @category_layouts_already_picked_by_a_position << key
  end

  def choose_placement_and_get_data(position_number)

    # Make sure there are some Category Placements for the position that was requested
    if @category_positions[position_number]

      # Store the position's Category Placements into a variable
      category_placements = @category_positions[position_number]

      # Lets look through all the valid Category Placements we have, and pick the first one that actually has data
      category_placements.each_with_index do | placement, index |
        category = placement.category

        # skip this Category Placement if it's Category has already been picked to be displayed in another Position for
        # the same layout type, UNLESS it's the last Category Placement
        # Perhaps a future code change could allow a "force" option to override this behavior
        if category_layout_already_picked? placement
          next unless index == category_placements.size - 1
        end

        data = category.data_for_school(@school)

        if data.rows.any?

          # Return a hash, since the caller needs the Category's school data, along with the Category Placement itself
          return { placement: placement, data: data }
        end
      end

      # Nothing matched, or no data found
      return nil
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

  def state_hash
    {
     'Alabama' => 'AL',
     'Alaska' => 'AK',
     'Arizona' => 'AZ',
     'Arkansas' => 'AR',
     'California' => 'CA',
     'Colorado' => 'CO',
     'Connecticut' => 'CT',
     'Delaware' => 'DE',
     'District of Columbia' => 'DC',
     'Florida' => 'FL',
     'Georgia' => 'GA',
     'Hawaii' => 'HI',
     'Idaho' => 'ID',
     'Illinois' => 'IL',
     'Indiana' => 'IN',
     'Iowa' => 'IA',
     'Kansas' => 'KS',
     'Kentucky' => 'KY',
     'Louisiana' => 'LA',
     'Maine' => 'ME',
     'Maryland' => 'MD',
     'Massachusetts' => 'MA',
     'Michigan' => 'MI',
     'Minnesota' => 'MN',
     'Mississippi' => 'MS',
     'Missouri' => 'MO',
     'Montana' => 'MT',
     'Nebraska' => 'NE',
     'Nevada' => 'NV',
     'New Hampshire' => 'NH',
     'New Jersey' => 'NJ',
     'New Mexico' => 'NM',
     'New York' => 'NY',
     'North Carolina' => 'NC',
     'North Dakota' => 'ND',
     'Ohio' => 'OH',
     'Oklahoma' => 'OK',
     'Oregon' => 'OR',
     'Pennsylvania' => 'PA',
     'Rhode Island' => 'RI',
     'South Carolina' => 'SC',
     'South Dakota' => 'SD',
     'Tennessee' => 'TN',
     'Texas' => 'TX',
     'Utah' => 'UT',
     'Vermont' => 'VT',
     'Virginia' => 'VA',
     'Washington' => 'WA',
     'West Virginia' => 'WV',
     'Wisconsin' => 'WI',
     'Wyoming' => 'WY'}
  end

end
