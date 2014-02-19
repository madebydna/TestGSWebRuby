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

  def data_for_school(school)
    school.data_for_category(self)
  end

  def possible_sources
    CategoryDataReader.sources
  end

end
