class Page < ActiveRecord::Base
  attr_accessible :name
  db_magic :connection => :profile_config

  include BelongsToCollectionConcerns

  has_many :category_placements, 
           inverse_of: :page,
           :order => 'collection_id desc'

  def self.by_name(name)
    page = where(name: name).preload(
      category_placements: { category: :category_datas}
    ).first
  end

  #
  # Returns all CategoryData keys configured on this page, for the given
  # source. For example, if both the "Ethnicity" category and "Details" 
  # category use a source called "census_data", then this method would return
  # all the keys configured for both Ethnicity and Details
  #
  # @param  source [String] The 'source' a.k.a. data reader
  #
  # @return [Array] Array of keys as strings
  def all_configured_keys(source)
      categories_using_source(source).map(&:keys).inject([], &:+)
  end

  def code_friendly_name
    name.gsub('&',' ').gsub(/\s+/, '_').classify
  end

  def categories
    @categories ||= category_placements.map(&:category).compact
  end

  def category_datas
    @category_datas ||=
      categories.map(&:category_datas).sort(&CategoryData.sort_order_proc)
  end

  def root_placements
    category_placements.select { |cp| cp.ancestry.nil? }.sort_by(&:position)
  end

  def categories_using_source(source)
    categories.select { |category| category.source == source }
  end

end
