module AttributeCaching
  class StateAttributesCacher < StateCacher
    CACHE_KEY = 'state_attributes'
    #157 is Growth Data (Student Progress Rating) and 159 is Growth Proxy Data (Academic Progress Rating)
    GROWTH_DATA_TYPES = [157, 159]

    def attributes
      %w(growth_type)
    end

    def growth_type
      @_growth_types_by_state ||=begin
        Omni::Rating.joins(data_set: :data_type)
          .where(data_sets: {data_type_id: GROWTH_DATA_TYPES, state: state})
          .school_entity
          .active
          .select('data_sets.state as state, data_types.name')
          .distinct
          .first
          &.name
      end
    end

    def build_hash_for_cache
      attributes.each_with_object({}) do |key, hash|
        case key
        when 'growth_type'
          hash[key] = growth_type == nil ? 'N/A' : growth_type
        end
      end
    end
  end
end