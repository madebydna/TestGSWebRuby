class Page < ActiveRecord::Base
  attr_accessible :name
  has_paper_trail
  db_magic :connection => :profile_config

  include BelongsToCollectionConcerns

  has_many :category_placements, 
           inverse_of: :page,
           :order => 'collection_id desc'

  def self.by_name(name)
    page = where(name: name).first
    page.preload_config_data
    page
  end

  # This method will return all of the various data keys that are configured to display for a certain *source*
  # This works by aggregating all of the CategoryData keys for Categories which use this source
  # For example, if both the "Ethnicity" category and "Details" category use a source called "census_data", then
  # this method would return all the keys configured for both Ethnicity and Details
  def all_configured_keys(source)
    Rails.cache.fetch("#{SchoolProfileConfigCaching::CATEGORY_DATA_KEYS_PER_SOURCE_PREFIX}/#{source}", expires_in: 1.hour) do
      all_keys = categories_using_source(source).map(&:keys).inject([], &:+)
    end
  end

  def code_friendly_name
    name.gsub('&',' ').gsub(/\s+/, '_').classify
  end

  def category_placements
    @category_placements ||= super
  end

  def categories
    @categories ||= category_placements.map(&:category).compact
  end

  def category_datas
    @category_datas ||= categories.map(&:category_datas)
  end

  def root_placements
    category_placements.select { |cp| cp.ancestry.nil? }.sort_by(&:position)
  end

  def categories_using_source(source)
    categories.select { |category| category.source == source }
  end

  def preload_config_data
    category_placements = self.category_placements.eager_load(:category)
    
    # Manually eager load category placements
    association = association(:category_placements)
    association.loaded!
    association.target.concat(category_placements)
    category_placements.each { |cp| association.set_inverse_instance(cp) }

    # Manually eager load CategoryData objects
    category_ids = category_placements.map(&:category).compact.map(&:id).uniq
    category_datas = CategoryData.
                      where(category_id: category_ids).
                      group_by(&:category_id)

    category_placements.map(&:category).compact.each do |category|
      records = category_datas[category.id]
      association = category.association(:category_datas)
      association.loaded!
      if records.present?
        association.target.concat(records.sort &CategoryData.sort_order_proc)
        records.each { |record| association.set_inverse_instance(record) }
      end
    end
  end

end
