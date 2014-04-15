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

  # Returns an array of Collection instances for a given school
  def self.for_school(school)
    collection_id = school.school_metadata['collection_id']
    if collection_id
      hub_city_mapping = HubCityMapping.for_collection_id(collection_id)
      if hub_city_mapping
        return [ Collection.from_hub_city_mapping(hub_city_mapping) ]
      end
    end

    return []
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
