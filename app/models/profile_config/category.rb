class Category < ActiveRecord::Base
  attr_accessible :description, :name, :parent, :source, :layout, :json_config, :updated_at
  db_magic :connection => :profile_config

  has_many :category_placements, -> { order('collection_id desc') }

  belongs_to :parent, :class_name => 'Category'
  has_many :categories, :foreign_key => 'parent_id'
  has_many :response_values, :foreign_key => 'category_id'
  has_many :category_datas, -> { order('category_id, sort_order ASC') }

  def category_data(collections = nil)
    category_datas.select do |category_data| 
      category_data.collection.nil? ||
      collections.blank? ||
      collections.map(&:id).include?(self.category_datas.first.collection.id)
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

  def key_label_map(translate = true, with_subjects = false)
    category_data.inject({}) do |map, cd|
      if cd.label(translate).present?
        if with_subjects
          map[[cd.response_key, cd.subject_id]] ||= cd.label(translate)
        else
          map[cd.response_key] ||= cd.label(translate)
        end
      end
      map
    end
  end

  def key_description_map(state, collections = nil)
    category_data(collections).
      select { |cd| cd.description_key.present? }.
      each_with_object({}) do |cd, map|
        description = DataDescription.description(state, cd.description_key)
        map[cd.response_key] ||= description if description.present?
      end
  end

  def code_name
    name.gsub /\W+/, '_'
  end

  def possible_sources
    SchoolProfileDataDecorator.data_readers
  end

  def parsed_json_config
    if json_config.present?
      JSON.parse(json_config).with_indifferent_access if json_config.present?
    else
      {}
    end
  end

end
