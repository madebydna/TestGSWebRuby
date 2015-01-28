class PageConfig
  attr_reader :page, :school, :page_has_data

  delegate :category_placements, :root_placements, to: :page

  def initialize(page_name, school)
    @page_has_data = false
    @school = school
    page = Page.by_name page_name

    if page.nil?
      raise ActiveRecord::RecordNotFound, "Could not read Page row from config db for page name: #{page_name}"
    end

    @page = page
  end

  def set_module_has_data
    @page_has_data = true
  end

  def root_placements_with_data
    root_placements.select { |cp| category_placement_has_data? cp }
  end

  def root_placements_with_profile_data
    @page_has_data ||= root_placements.select { |cp| category_placement_has_profile_data? cp }
  end

  def category_placement_children_with_data(parent)
    parent.children.select { |cp| category_placement_has_data? cp }
  end

  def category_placement_children_with_profile_data(parent)
    parent.children.select { |cp| category_placement_has_profile_data? cp }
  end

  def category_placement_has_data?(cp)
    @category_placement_has_data ||= {}
    @category_placement_has_data[cp.cache_key] ||= (
      if cp.has_children?
        category_placement_children_with_data(cp).any?
      else
        cp.category.nil? || cp.category.has_data?(school, page_config: self)
      end
    )
  end

  def category_placement_has_profile_data?(cp)
    @category_placement_has_profile_data ||= {}
    @category_placement_has_profile_data[cp.cache_key] ||= (
    if cp.has_children?
      category_placement_children_with_profile_data(cp).any?
    else
      cp.category && cp.category.has_data?(school, page_config: self)
    end
    )
  end

  def method_missing(name, *args, &block)
    page.send name, *args, &block
  end

end