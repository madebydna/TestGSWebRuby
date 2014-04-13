class CategoryPlacement < ActiveRecord::Base
  attr_accessible :category, :page, :position, :category_id, :page_id, :layout, :layout_config, :priority, :title
  has_paper_trail
  has_ancestry
  db_magic :connection => :profile_config

  include BelongsToCollectionConcerns
  belongs_to :category
  belongs_to :page, inverse_of: :category_placements

  after_initialize :set_defaults
  before_validation :parse_layout_json

  # creates a key that identifies this placement's category on a specific page, with a specific format
  def page_category_layout_key
    "page#{page.id}_category#{category.id}_layout#{layout}"
  end

  # layout name => partial name
  # Used by rails_admin to populate dropdown list of layouts
  def possible_layouts
    file_names = Dir.entries(Rails.root.join('app', 'views', 'data_layouts').to_s)

    # Remove invalid files from listing, e.g. '.' and '..'
    file_names.reject! { |f| f =~ /^\W+$/ }

    # Remove file extensions
    file_names.each { |f| f.slice!(f.index('.')..-1) }

    # creates something like  { "Layout name" => "layout_name" }
    file_names.inject({}) do |hash, file_name|
      pretty_name = file_name.gsub(/_/, ' ').strip.capitalize
      # [1..-1] to remove the underscore in front of the filename
      hash[pretty_name] = file_name[1..-1]
      hash
    end
  end

  # return CategoryPlacements with collection_id in the provided
  # collections. If a single object is passed in, the Array(...) call will convert it to an array
  # Will return CategoryPlacements with nil collection_id
  def self.belonging_to_collections(page, collections = nil)
    placements_for_page(page).select do |category_placement|
      array_of_ids_with_nil = (Array(collections).map(&:id))<<nil
      array_of_ids_with_nil.include? category_placement.collection_id
    end
  end

  def self.placements_for_page(page)
    Rails.cache.fetch("#{SchoolProfileConfigCaching::CATEGORY_PLACEMENTS_PER_PAGE_PREFIX}#{page.name.gsub(/\s+/,'_')}", expires_in: 5.minutes) do
      order('position asc').order('priority').order('collection_id desc').where(page_id:page.id).all
    end
  end

  def set_defaults
    self.layout ||= 'default_two_column_table' if self.has_attribute? :layout
  end

  def parse_layout_json
      self.layout_config = JSON.parse(layout_config).to_json if layout_config.present?
  end

  def layout_config_json
    if layout_config.present?
      JSON.parse(layout_config) if layout_config.present?
    else
      {}
    end
  end

  def table_config
    TableConfig.new(layout_config_json)
  end

  def full_width_on_display?(display_size)
    return true if root?

    return self.size_for_display(display_size) == 12
  end

  def full_width_on_all_displays?
    sizes.values == [12,12,12,12]
  end

  def my_sizes
    sizes = { 'xs' => 12, 'sm' => 12, 'md' => 12, 'lg' => 12 }
    if layout_config_json['sizes']
      sizes.merge! layout_config_json['sizes'] if layout_config_json['sizes']
    end
    sizes
  end

  def parent_enforced_sizes
    sizes = {}
    position_among_siblings = siblings.map(&:id).index(self.id)
    parent_json = parent.layout_config_json
    if parent_json['child_sizes'].present? && parent_json['child_sizes'].length > position_among_siblings
      sizes = parent_json['child_sizes'][position_among_siblings]
    end
    sizes
  end

  def sizes
    sizes = self.my_sizes
    sizes.merge! parent_enforced_sizes if !root?
    sizes
  end

  def sizes_css_string
    string = ''
    sizes.each do |key, value|
      string << " col-#{key}-#{value}"
    end
    string
  end

  def size_for_display(display_size)
    self.sizes[display_size]
  end

  def first_sibling?
    siblings.first == self
  end

  def last_sibling?
    siblings.last == self
  end

  def partial
    "data_layouts/#{layout}"
  end

  def parent
    page.category_placements.find { |cp| self.parent_id == cp.id }
  end

  def siblings
    parent.children.sort_by(&:position)
  end

  def children
    page.category_placements.select do |cp| 
      cp.parent_id == id
    end.sort_by(&:position)
  end

  def has_children?
    children.any?
  end

  def descendants
    page.category_placements.select do |cp| 
      Array(cp.ancestor_ids).include?(id)
    end
  end

  def leaves
    # Descendant is any descendant below this node at any level
    descendants.reject do |descendant| 
      descendant.has_children?
    end.sort_by(&:position)
  end

end
