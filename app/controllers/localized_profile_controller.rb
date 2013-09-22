class LocalizedProfileController < ApplicationController
  protect_from_forgery

  # Find school before executing culture action
  before_filter :find_school

  layout 'application'

  def overview
    page('Overview')
    @category_positions = @page.categories_per_position(@school.collections)
    @category_placements =  choose_category_placements
  end

  def quality
    page('Quality')
    @category_positions = @page.categories_per_position(@school.collections)
    @category_placements =  choose_category_placements
  end
  def details
    page('Details')
    @category_positions = @page.categories_per_position(@school.collections)
    @category_placements =  choose_category_placements
  end
  def reviews
    page('Reviews')
    @category_positions = @page.categories_per_position(@school.collections)
    @category_placements =  choose_category_placements
  end

  def choose_category_placements
    category_placement_data={}
    (1..6).each do |position_number|
      category_p_d=choose_placement_and_get_data(position_number)
      category_placement_data[position_number]=category_p_d
    end
    category_placement_data
  end

  #def programs_resources
  #  page('Programs & resources')
  #  @category_positions = @page.categories_per_position(@school.collections)
  #  render :layout => 'application' # TODO: why do we need to use this? ApplicationController should render this by default
  #end
  #
  #def extracurriculars
  #  page('Extracurriculars')
  #  @category_positions = @page.categories_per_position(@school.collections)
  #  render :layout => 'application' # TODO: why do we need to use this? ApplicationController should render this by default
  #end

  def page(name)
    @page = Page.using(:master).where(name: name).first
  end

  # Finds school given request param schoolId
  def find_school
    state = params[:state] || 'ca'
    school_id = params[:schoolId] || 1

    if school_id.nil?
      # todo: redirect to school controller, school_not_found action
    end

    @school = School.using(state.upcase.to_sym).find school_id
  end
  def page_category_layout_key(placement)
    key = "page#{placement.page.id}_category#{placement.category.id}_layout#{placement.layout}"
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
          return {placement: placement, data: data}
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


end
