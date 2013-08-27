class CultureController < LocalizedProfileController

  # Find school before executing culture action
  before_filter :find_school, only: [:culture2, :culture3]
  before_filter :page, only: [:culture2, :culture3]

  def initialize
    @category_positions = {}
  end

  def culture3
    @category_positions = @page.categories_per_position(@school.collections)
    render :layout => "application"
  end

  def culture2
    # for this page, lets build a hash that tells us what category of data to put at each position
    if @page.category_placements
      @category_positions = category_placements.inject({}) do |map, category_placement|

        # Skip this category_placement if its collection doesnt match school's collection
        next unless category_placement.collection.nil? ||
            (@school.collections && @school.collections.include?(category_placement.collection))

        map[category_placement.position.to_s] ||= category_placement

        map # the block's return value gets put into the 'map' argument subsequent iterations
      end
    end

    # now find all school school
    school_category_data = @school.school_category_datas

    # Build a hash of school category to array of rows
    # Inject passes it's argument as the first param to the block on the first iteration, and
    # the return value of the block on subsequent iterations
    @school_category_data_map = school_category_data.inject({}) do |map, school_category_data_row|
      map[school_category_data_row.category] ||= []
      map[school_category_data_row.category].push school_category_data_row
      map
    end

  end

  # Finds school given request param schoolId
  def find_school
    school_id = params[:schoolId]

    if school_id.nil?
      # todo: redirect to school controller, school_not_found action
    end

    @school = School.find school_id
  end


  def page
    @page = Page.where(name: 'Extracurriculars').first
  end

  def culture
    @schoolId = params[:schoolId]
    @schoolCollection = SchoolCollection.find(@schoolId)
    @schoolCategoryData = SchoolCategoryData.find(@schoolCollection)
    #SchoolCategoryData.find(@schoolCollection).each do |collection|
    #   collection.Category.name
    #end

    #@category = Category.all
    @message = "message to view"

  end
end
