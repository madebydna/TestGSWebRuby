class LocalizedProfileController < ApplicationController
  protect_from_forgery

  # Find school before executing culture action
  before_filter :find_school, :find_user

  layout :choose_profile_layout

  def choose_profile_layout
    @java = params[:java] == 'java'
    @java? 'application' : 'application'
  end

  def overview
    page('Overview')
    @category_positions = @page.categories_per_position(@school.collections)
    @category_placements =  choose_category_placements
    initHeader
  end

  def quality
    page('Quality')
    @category_positions = @page.categories_per_position(@school.collections)
    @category_placements =  choose_category_placements
    initHeader
  end

  def details
    page('Details')
    @category_positions = @page.categories_per_position(@school.collections)
    @category_placements =  choose_category_placements
    initHeader
  end

  def reviews
    page('Reviews')
    initHeader
    @school_reviews = @school.reviews_filter '', '', '', 10

    @review_offset = 0
    @review_limit = 10

  end

  def choose_category_placements
    @category_positions.keys.sort.inject({}) do |hash, position|
      hash[position] = choose_placement_and_get_data(position)
      hash
    end
  end

  def page(name)
    @page = Page.using(:master).where(name: name).first
  end

  def find_user
    member_id = cookies[:MEMID]
    @user = User.find member_id unless member_id.nil?
    @user_first_name = @user.first_name unless @user.nil?
  end



  # true if category was already chosen to be displayed with associated layout.
  def category_layout_already_picked?(placement)
    @category_layouts_already_picked_by_a_position ||= []
    key = placement.page_category_layout_key
    @category_layouts_already_picked_by_a_position.include? key
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
          # Return a hash, since the caller needs the Category's school data, along with the Category Placement itself
          return {placement: placement, data: data}
        end
      end

      # Nothing matched, or no data found
      return nil
    end
  end

  def test_scores
    page('TestScores')
    initHeader
  end

  def initHeader
    @headerMetadata = @school.school_metadata

    @school_reviews_global = SchoolReviews.set_reviews_objects @school

  end
end
