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
    category_datas.select do |category_data| 
      category_data.collection.nil? ||
      collections.blank? ||
      collections.include?(category_data.collection)
    end
  end

  def has_data?(school, options = {})
    options[:category] = self
    return true if source.blank?
    if school.respond_to?(:data_for_category)
      return school.data_for_category(options).present?
    end
    return false
  end

  def keys(collections = nil)
    category_data(collections).map(&:response_key)
  end

  def key_label_map(collections = nil)
    category_data(collections).inject({}) do |map, category_data_row|
      map[category_data_row.response_key.downcase] ||= category_data_row.label
      map
    end
  end

  def code_name
    name.gsub /\W+/, '_'
  end

  def possible_sources
    SchoolProfileDataDecorator.data_readers
  end

end
