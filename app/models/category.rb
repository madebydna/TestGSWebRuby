class Category < ActiveRecord::Base
  attr_accessible :description, :name, :parent, :source

  has_paper_trail

  has_many :category_placements, :order => 'collection_id desc'

  belongs_to :parent, :class_name => 'Category'
  has_many :categories, :foreign_key => 'parent_id'
  has_many :category_datas


  def category_data(collections = nil)
      CategoryData.using(:master).belonging_to_collections(self, collections)
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
=begin
    if source.nil?
      return values_for_school(school)
    else
      return data_reader.json_data(school)
    end
=end
    data_reader.prettify_data(school, data_reader.table_data(school))
  end

  def data_reader
    return @data_reader if @data_reader
    default_class = 'EspResponseReader'

    class_name = source || default_class

    begin
      @data_reader = class_name.constantize.new(self)
    rescue
      @data_reader = default_class.constantize.new(self)
    end
  end

  # returns a label => pretty value map for this category
  def values_for_school(school)
    #key_label_map = school.key_label_map(self)

    all_school_data = EspResponse.using(school.state.upcase.to_sym).where(school_id: school.id)

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
