class Collection
  attr_accessor :id, :name, :description


  # Note that this is ok since this class is not an ActiveRecord class
  # If you ever make this class extend from ActiveRecord, you'll have to remove this initialize method
  def initialize(params)
    params.each do |key, value|
      self.instance_variable_set("@#{key}".to_sym, value)
    end
  end

  def self.from_hub_city_mapping(hub_city_mapping)
    return nil if hub_city_mapping.nil?

    Collection.new(
      id: hub_city_mapping.collection_id,
      name: hub_city_mapping.city,
      description: hub_city_mapping.city
    )
  end

  def self.find(id)
    hub_city_mapping = HubCityMapping.where(collection_id: id).first
    if hub_city_mapping
      Collection.from_hub_city_mapping hub_city_mapping
    end
  end

  def self.all
    hub_city_mappings = HubCityMapping.all
    hub_city_mappings.map { |hub_city_mapping| Collection.from_hub_city_mapping hub_city_mapping }
  end

end
