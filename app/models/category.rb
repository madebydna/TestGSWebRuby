class Category < ActiveRecord::Base
  attr_accessible :description, :name, :parent, :source

  has_many :category_placements, :order => 'collection_id desc'

  belongs_to :parent, :class_name => 'Category'
  has_many :categories, :foreign_key => 'parent_id'
  has_many :category_datas

  def category_data(collections = nil)
      CategoryData.belonging_to_collections(self, collections)
  end

  def key_label_map(collections = nil)
    category_data(collections).inject({}) do |map, category_data_row|
      map[category_data_row.response_key] ||= category_data_row.response_label
      map
    end
  end

  def data_for_school(school)
    if source.nil?
      return values_for_school(school)
    else
      data_reader = source.constantize.new
      return data_reader.get_data(school)
    end
  end

  # returns a label => pretty value map for this category
  def values_for_school(school)
    key_label_map = school.key_label_map(self)

    all_school_data = SchoolCategoryData.where(school_id: school.id)

    pp key_label_map.keys

    # We grabbed all the school's data, so we need to filter out rows that dont have the keys that we need
    all_school_data.select! { |data| key_label_map.keys.include? data.key}

    all_school_data.inject({}) do |hash, school_data|
      key = school_data.key
      value = school_data.value

      label = key_label_map[key] || key
      hash[label] ||= []
      pretty_value = ResponseValue.pretty_value(value, school.collections)

      hash[label] << pretty_value

      # remove duplicates from the array
      hash[label].uniq!
      hash
    end
  end

end
