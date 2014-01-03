class PageConfig
  attr_reader :configured_placements_per_position, :position_datas, :school

  def initialize(page_name, school)
    @school = school
    page = Page.by_name page_name

    if page.nil?
      raise ActiveRecord::RecordNotFound, "Could not read Page row from config db for page name: #{page_name}"
    end

    @page = page
    @position_datas = page.category_placements
  end

  def placements
    @position_datas
  end

  def root_placements
    @position_datas.select(&:root?).sort_by(&:position)
  end

  def root_placements_with_data
    root_placements.select{ |placement| placement.has_data?(school) }
  end

end