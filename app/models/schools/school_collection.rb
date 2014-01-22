require 'states'
class SchoolCollection
  attr_accessor :school_id, :school_state, :school, :collection_id, :collection

  # Note that this is ok since this class is not an ActiveRecord class
  # If you ever make this class extend from ActiveRecord, you'll have to remove this initialize method
  def initialize(params)
    params.each do |key, value|
      self.instance_variable_set("@#{key}".to_sym, value)
    end
  end

  def self.from_hub_city_mapping(hub_city_mapping)
    collection = Collection.from_hub_city_mapping hub_city_mapping
    shard = hub_city_mapping.state.downcase.to_sym

    # Important: The School.on_db block is required here, as opposed to a School.on_db chained call.
    # This is because db_charmer doesn't correctly handle chaining with a pluck() method call, as far as I can tell
    school_ids = []
    School.on_db(shard) do
      school_ids = School.where(city: hub_city_mapping.city).pluck(:id)
    end

    school_collections = school_ids.map do |school_id|
      SchoolCollection.new(
        school_id: school_id,
        school_state: hub_city_mapping.state.downcase,
        collection: collection
      )
    end
  end

  # Return an array of all SchoolCollections based on what's in hub_city_mapping
  # Clients that just need a subset, should just use this method (since it'll always need to two queries, one to
  # get all collections, and one to get the school IDs associated with the collection)
  #
  # Results should be cached so these queries execute rarely
  def self.all(state = nil)
    hub_city_mappings = HubCityMapping.all

    if state.present?
      hub_city_mappings = hub_city_mappings.select! { |hub_city_mapping| hub_city_mapping.state.match /^#{state}$/i }
    end

    results = hub_city_mappings.inject([]) do |array, hub_city_mapping|
      array += SchoolCollection.from_hub_city_mapping(hub_city_mapping)
      array
    end
    results
  end

  def self.for_school(school)
    all(school.state).select do |school_collection|
      school_collection.school_id == school.id && school_collection.school_state.match(/^#{school.state}$/i)
    end
  end

  def self.for_collection(collection)
    all.select { |school_collection| school_collection.collection_id == collection.id }
  end


  # Immediately returns @school if present, otherwise runs query to find school by school_id
  def school
    @school ||= School.on_db(@school_state.downcase.to_sym).find(@school_id) rescue nil
  end

  # Immediately return @collection if present, otherwise runs query to find Collection by hitting hub_city_mapping
  def collection
    @collection ||= Collection.find @collection_id
  end

  # When school is set, also set school ID and state
  def school=(school)
    @school = school
    @school_state = school.state.downcase
    @school_id = school.id
  end

  # When collection is set, also set collection ID
  def collection=(collection)
    @collection = collection
    @collection_id = collection.id
  end

  # When collection ID is set, also set collection
  def collection_id=(collection_id)
    @collection_id = collection_id
    @collection = Collection.find collection_id
  end

end
