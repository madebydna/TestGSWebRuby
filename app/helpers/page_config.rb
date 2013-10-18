class PageConfig
  attr_reader :category_positions, :category_placements

  def initialize(page_name, school)
    @school = school
    page = Page.where(name: page_name).first

    if page.nil?
      raise ActiveRecord::RecordNotFound, "Could not read Page row from config db for page name: #{page_name}"
    end

    @page = page
    @category_positions = page.categories_per_position(school.collections)
    @category_placements =  choose_category_placements
  end

  def position_exists?(position_number)
    @category_positions[position_number].present?
  end

  def position_has_data?(position_number)
    return false if @category_positions[position_number].nil?
    placement_and_data = @category_placements[position_number]
    placement_and_data.present? && placement_and_data[:data].present?
  end

  def category_placement_at_position(position_number)
    @category_placements[position_number][:placement]
  end

  def data_at_position(position_number)
    @category_placements[position_number][:data]
  end

  # An array of the chosen category placements, ordered by position
  def placements
    @category_placements.values.map{ |placement_and_data| placement_and_data[:placement] }
  end

  def choose_category_placements
    @category_positions.keys.sort.inject({}) do |hash, position|
      hash[position] = choose_placement_and_get_data(position)
      hash
    end
  end

  # Given a hash of category_positions exists, determine the correct category_placement to display at a position
  # Requests data for each category to check eligibility
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

        if data
          mark_category_layout_picked placement

          # Return a hash, since the caller needs the Category's school data, along with the Category Placement itself
          return {placement: placement, data: data}
        end
      end

      # Nothing matched, or no data found
      return nil
    end
  end

  # true if category was already chosen to be displayed with associated layout.
  def category_layout_already_picked?(placement)
    @category_layouts_already_picked_by_a_position ||= []
    key = placement.page_category_layout_key
    @category_layouts_already_picked_by_a_position.include? key
  end

  def mark_category_layout_picked(placement)
    key = placement.page_category_layout_key
    @category_layouts_already_picked_by_a_position ||= []
    @category_layouts_already_picked_by_a_position << key
  end

end