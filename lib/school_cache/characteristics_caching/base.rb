class CharacteristicsCaching::Base

  @@characteristics_data_types = Hash[CensusDataType.all.map { |f| [f.id, f] }]
  @@characteristics_data_breakdowns = Hash[CensusDataBreakdown.all.map { |f| [f.id, f] }]
  @@characteristics_descriptions = Hash[CensusDescription.all.map { |f| [f.census_data_set_id.to_s+f.state, f] }]

  cattr_accessor :characteristics_data_types, :characteristics_data_breakdowns, :characteristics_descriptions

  attr_accessor :school

  def initialize(school)
    @school = school
  end

  def characteristics_data_types
    @@characteristics_data_types
  end

  def characteristics_descriptions
    @@characteristics_descriptions
  end

  def characteristics_data_breakdowns
    @@characteristics_data_breakdowns
  end

  def build_hash_for_cache
    raise NotImplementedError
  end

  def cache
    final_hash = build_hash_for_cache

    school_cache = SchoolCache.find_or_initialize_by(
        school_id: school.id,
        state: school.state,
        name:self.class::CACHE_KEY
    )

    if final_hash.present?
      school_cache.update_attributes!(
          value: final_hash.to_json,
          updated: Time.now
      )
    elsif school_cache && school_cache.id.present?
      SchoolCache.destroy(school_cache.id)
    end
  end

  def active_record_to_hash(configuration_map, obj)
    rval_map = {}
    configuration_map.each do |key, val|
      if obj.attributes.include?(key.to_s)
        rval_map[val] = obj[key]
      elsif obj.respond_to?(key)
        rval_map[val] = obj.send(key)
      else
        Rails.logger.error "ERROR: Can't find attribute or method named #{key} in #{obj}"
      end
    end
    rval_map
  end

end