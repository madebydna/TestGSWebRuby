module CachePopulator
  class CityCachePopulator < Base
    CACHE_KEYS = %w(header school_levels district_content)

    def initialize(values:, cache_keys:)
      super
      # default for blank state
      @states = ['no state'] if @states.empty?
    end

    def run
      run_with_validation do |state, cache_key|
        cities_to_cache(state).each do |city|
          CityCacher.create_cache(city, cache_key)
          @rows_updated += 1
        end
      end
      rows_updated
    end

    def cities_to_cache(state)
      if state == 'all' 
        City.get_all_cities
      elsif state == 'no state' && optional_ids.present?
        City.where(parse_optional_ids)
      else
        City.where(state: state)
      end
    end

    # if states = 'all', do not return array of all states
    def states_to_cache
      states
    end

    private

    # overriding state validation check to account for 'no state' option
    def check_for_valid_states
      unless states.present? && 
        (states.first == 'all' || states.first == 'no state' || 
          states.all? {|key| States.abbreviations.include?(key)})
        errors.add(:states, "unless blank must have the value 'all' or be a list of valid states")
      end
    end
  end
end