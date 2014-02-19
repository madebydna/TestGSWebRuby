class Collection
  attr_accessor :id, :name, :hub_city_mapping

  # Note that this is ok since this class is not an ActiveRecord class
  # If you ever make this class extend from ActiveRecord, you'll have to remove this initialize method
  def initialize(params)
    params.each do |key, value|
      self.instance_variable_set("@#{key}".to_sym, value)
    end
  end

  delegate :has_edu_page?, :has_choose_page?, :has_events_page?, :has_enroll_page?, :has_partner_page?, to: :hub_city_mapping

  def config
    @config ||= CollectionConfig.key_value_map self.id
  end

  def nickname
    config['collection_nickname'] || name
  end

  def self.from_hub_city_mapping(hub_city_mapping)
    return nil if hub_city_mapping.nil?

    Collection.new(
      id: hub_city_mapping.collection_id,
      name: hub_city_mapping.city,
      hub_city_mapping: hub_city_mapping
    )
  end

  def self.find(id)
    hub_city_mapping = HubCityMapping.for_collection_id(id).first
    if hub_city_mapping
      Collection.from_hub_city_mapping hub_city_mapping
    end
  end

  def self.all
    hub_city_mappings = HubCityMapping.all
    hub_city_mappings.map { |hub_city_mapping| Collection.from_hub_city_mapping hub_city_mapping }
  end

end
