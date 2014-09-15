class CategoryData < ActiveRecord::Base
  attr_accessible :category_id,
                  :category,
                  :collection_id,
                  :collection,
                  :response_key,
                  :source,
                  :sort_order,
                  :label,
                  :json_config,
                  :rails_admin_category_data_key,
                  :rails_admin_category_data_key_freeform

  cattr_accessor :jsonified_attributes

  db_magic :connection => :profile_config

  include BelongsToCollectionConcerns
  belongs_to :category

  # valid types:  :integer | :string
  def self.jsonified_attribute(attribute_name, type = :string)
    self.jsonified_attributes ||= []
    self.jsonified_attributes << attribute_name
    attr_accessible attribute_name

    # define setter
    define_method("#{attribute_name}=") do |value|
      value = value.to_i if value.present? && type == :integer
      instance_variable_set("@#{attribute_name}", value)
      write_json_config
    end
    # define getter
    define_method(attribute_name) do
      json_config.try(:fetch, attribute_name.to_s, nil)
    end
  end

  jsonified_attribute :subject_id, :integer
  jsonified_attribute :description_key
  jsonified_attribute :icon_css_class

  # return CategoryData with collection_id in the provided
  # collections. If a single object is passed in, the Array(...) call will convert it to an array
  # Will return CategoryData with nil collection_id
  def self.belonging_to_collections(category, collections = nil)
    all_data_for_category(category).select do |category_data|
      array_of_ids_with_nil = (Array(collections).map(&:id))<<nil
      array_of_ids_with_nil.include? category_data.collection_id
    end
  end

  def self.all_data_for_category(category)
    Rails.cache.fetch("#{SchoolProfileConfigCaching::CATEGORY_DATA_PER_CATEGORY_PREFIX}#{category.name.gsub(/\s+/,'_')}", expires_in: 5.minutes) do
      order('category_id asc').order('collection_id desc').where(category_id:category.id).all
    end
  end

  def write_json_config
    hash = jsonified_attributes.each_with_object({}) do |attribute_name, h|
      value = instance_variable_get("@#{attribute_name}")
      if value.present?
        h[attribute_name] = value
      end
    end
    json = hash.present? ? hash.to_json : nil
    write_attribute(:json_config, json)
    @parsed_json_config = nil
  end

  def json_config
    @parsed_json_config ||= (
      json = read_attribute(:json_config)
      if json.present?
        JSON.parse(json) rescue {}
      else
        {}
      end
    )
  end

  def possible_sources
    SchoolProfileDataDecorator.data_readers
  end

  def self.sort_order_proc
    Proc.new do |cd1, cd2|
      if cd1.sort_order == cd2.sort_order
        cd1.id <=> cd2.id
      elsif cd1.sort_order && cd2.sort_order
        cd1.sort_order <=> cd2.sort_order
      else
        cd1.sort_order ? -1 : 1
      end
    end
  end

  def response_key
    key = super
    return nil if key.nil?
    key.match(/\A\d+\z/) ? key.to_i : key.downcase
  end

  def computed_label
    return label if label.present?

    case key_type
    when 'census_data'
      if response_key.is_a? Fixnum
        CensusDataType.description_for_id(response_key)
      else
        response_key
      end
    else
      response_key
    end
  end

  def computed_description(state)
    return unless description_key.present?
    DataDescription.description(state, description_key)
  end

  # Behavior to support RailsAdmin below here

  KEY_TYPES = {
    esp_response: 'ESP',
    census_data: 'CDT'
  }

  def rails_admin_response_keys
    data_types = Rails.cache.fetch("CategoryData/rails_admin_response_keys",
      expires_in: 5.minutes) do
      key_id_hash = {}
      key_id_hash.merge! esp_response_dropdown_values
      key_id_hash.merge! census_data_type_dropdown_values
      key_id_hash
    end
  end

  def esp_response_dropdown_values
    key_type_string = KEY_TYPES[:esp_response]
    keys = []
    # States.abbreviations_as_symbols.each do |state|
    #   keys +=
    #     (EspResponse.on_db(state.to_sym).all.map(&:response_key) rescue [])
    # end
    # keys.uniq!
    esp_response_key_hash = {}
    keys.each do |key|
      esp_response_key_hash["#{key_type_string}: #{key}"] =
        "esp_response:::#{key}"
    end
    esp_response_key_hash
  end

  def census_data_type_dropdown_values
    key_type_string = KEY_TYPES[:census_data]
    census_data_type_hash =
      CensusDataType.description_id_hash.gs_rename_keys do |key|
        "#{key_type_string}: #{key}"
      end

    census_data_type_hash.gs_transform_values! do |v|
      "census_data:::#{v}"
    end
  end

  def rails_admin_category_data_key
    return response_key if key_type.blank?
    "#{key_type}:::#{response_key}"
  end

  def rails_admin_category_data_key=(composite_key)
    key_type, id = composite_key.split(':::')
    self.key_type = key_type
    self.response_key = id
  end

  def rails_admin_category_data_key_freeform
    nil
  end
  def rails_admin_category_data_key_freeform=(text)
    if text.present?
      self.key_type = 'esp_response'
      self.response_key = text
    end
  end

  def self.rails_admin_description_keys
    DataDescription.pluck(:data_key).uniq
  end

end
