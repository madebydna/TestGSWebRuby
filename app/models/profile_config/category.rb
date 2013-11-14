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

  def key_label_map(collections = nil)
    category_data(collections).inject({}) do |map, category_data_row|
      map[category_data_row.response_key] ||= category_data_row.response_key
      map
    end
  end

  def code_name
    name.gsub /\W+/, '_'
  end

  def data_for_school(school)
    # TODO: don't fall back to EspResponse - update seeds to specify it in the config
    method_name = (source || 'EspResponse').underscore.to_sym
    CategoryDataReader.send method_name, school, self
  end

  # returns a label => pretty value map for this category
  def values_for_school(school)
    #key_label_map = school.key_label_map(self)

    all_school_data = EspResponse.on_db(school.shard).where(school_id: school.id)

    #pp key_label_map.keys

    keys_to_use = category_data(school.collections).map(&:response_key)


    # We grabbed all the school's data, so we need to filter out rows that dont have the keys that we need
    all_school_data.select! { |data| keys_to_use.include? data.key}

    all_school_data.inject({}) do |hash, school_data|
      key = school_data.response_key
      value = school_data.response_value

      hash[key] ||= []
      pretty_value = ResponseValue.pretty_value(value, school.collections)

      hash[key] << pretty_value

      # remove duplicates from the array
      hash[key].uniq!
      hash
    end
  end

end
