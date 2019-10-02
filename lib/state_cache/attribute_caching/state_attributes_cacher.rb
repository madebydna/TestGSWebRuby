module AttributeCaching
  class StateAttributesCacher < StateCacher
    CACHE_KEY = 'state_attributes'
    #157 is Growth Data (Student Progress Rating) and 159 is Growth Proxy Data (Academic Progress Rating)
    GROWTH_DATA_TYPES = [157, 159]

    def attributes
      %w(growth_type hs_enabled_growth_rating)
    end

    def growth_type_rating
      @_growth_types_by_state ||=begin
        Omni::Rating.joins(data_set: :data_type)
          .where(data_sets: {data_type_id: GROWTH_DATA_TYPES, state: state})
          .school_entity
          .order('data_sets.date_valid DESC')
          .active
          .select('data_sets.state as state, data_types.name')
          .distinct
          .first
          &.name
      end
    end

    # this method finds all schools with growth data in a state and bitwise and with all high schools in that state
    # This is to see if high schools in a particular state should display the growth/growth proxy data module on school profiles
    def hs_enabled_growth_rating?
      schools_ids_with_growth_ratings = Omni::Rating.joins(data_set: :data_type).where(data_sets: {data_type_id: GROWTH_DATA_TYPES, state: state}).school_entity.active.select(:gs_id).distinct.map(&:gs_id)
      high_schools_ids = School.on_db(state) { School.active.where(level_code: 'h').pluck(:id)}
      (schools_ids_with_growth_ratings & high_schools_ids).length > 0
    end

    def build_hash_for_cache
      attributes.each_with_object({}) do |key, hash|
        case key
        when 'growth_type'
          hash[key] = growth_type_rating == nil ? 'N/A' : growth_type_rating
        when 'hs_enabled_growth_rating'
          hash[key] = hs_enabled_growth_rating?
        end
      end
    end
  end
end