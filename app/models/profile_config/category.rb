class Category < ActiveRecord::Base
  attr_accessible :description, :name, :parent, :source, :layout
  has_paper_trail
  db_magic :connection => :profile_config

  has_many :category_placements, :order => 'collection_id desc'

  belongs_to :parent, :class_name => 'Category'
  has_many :categories, :foreign_key => 'parent_id'
  has_many :response_values, :foreign_key => 'category_id'
  has_many :category_datas


  def category_data(collections = nil)
      CategoryData.on_db(:profile_config).order('sort_order asc').belonging_to_collections(self, collections)
  end

  def has_data?(school)
    return true if source.blank?
    school.data_for_category(self).present?
  end

  def keys(collections = nil)
    category_data(collections).map(&:response_key)
  end

  def key_label_map(collections = nil)
    category_data(collections).inject({}) do |map, category_data_row|
      map[category_data_row.response_key] ||= category_data_row.label
      map
    end
  end

  def code_name
    name.gsub /\W+/, '_'
  end

  def possible_sources
    SchoolProfileDataReader.data_readers
  end

  # This method will return all of the various data keys that are configured to display for a certain *source*
  # This works by aggregating all of the CategoryData keys for Categories which use this source
  # For example, if both the "Ethnicity" category and "Details" category use a source called "census_data", then
  # this method would return all the keys configured for both Ethnicity and Details
  def self.all_configured_keys(source)
    cache_key = "all_configured_keys-source:#{source}"
    Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      categories_using_source = Category.where(source: source).all

      all_keys = []
      categories_using_source.each{ |category| all_keys += category.keys }

      # Add in keys where source is specified in CategoryData
      all_keys += CategoryData.where(source: source).pluck(:response_key)
    end
  end

end
