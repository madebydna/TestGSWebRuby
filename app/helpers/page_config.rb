class PageConfig
  attr_reader :page, :school

  def initialize(page_name, school)
    @school = school
    page = Page.by_name page_name

    if page.nil?
      raise ActiveRecord::RecordNotFound, "Could not read Page row from config db for page name: #{page_name}"
    end

    @page = page
    initialize_category_placements
  end

  def initialize_category_placements
    @category_placements = page.category_placements.eager_load(:category)
    @category_placements_id_hash = @category_placements.each_with_object({}) do |cp, hash|
      hash[cp.id] = cp
      cp.memoized_children = []
    end
    @category_placements.each do |cp|
      if cp.ancestry.present?
        parent = @category_placements_id_hash[cp.parent_id]
        cp.memoized_parent = parent
        children = (parent.memoized_children || []) << cp
        parent.memoized_children = children.sort_by(&:position)
      end
    end
  end

  def category_placements
    @category_placements ||= page.category_placements
  end

  def root_placements
    category_placements.select { |cp| cp.ancestry.nil? }.sort_by(&:position)
  end

  def root_placements_with_data
    root_placements.select { |cp| category_placement_has_data? cp }
  end

  def category_placement_children(parent)
    category_placements.select { |cp| cp.parent_id == parent.id }.sort_by(&:position)
  end

  def category_placement_has_children?(cp)
    category_placement_children(cp).any?
  end

  def category_placement_descendants(parent)
    category_placements.select { |cp| Array(cp.ancestor_ids).include?(parent.id) }
  end

  def category_placement_leaves(cp)
    category_placement_descendants(cp).reject { |descendant_cp| category_placement_has_children? descendant_cp }.sort_by(&:position)
  end

  def category_placement_parent(child)
    category_placements.detect { |cp| child.parent_id == cp.id }
  end

  def category_placement_children_with_data(parent)
    category_placement_children(parent).select { |cp| category_placement_has_data? cp }
  end

  def category_placement_has_data?(cp)
    @category_placement_has_data ||= {}
    @category_placement_has_data[cp.cache_key] ||= (
      if category_placement_has_children? cp
        category_placement_children_with_data(cp).any?
      else
        cp.category.nil? || cp.category.has_data?(school, page_config: self)
      end
    )
  end

end