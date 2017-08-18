module Feeds
  class TestCalculations
    include Feeds::FeedConstants

    def self.calculate_universal_id(state, entity_level = nil, entity_id = nil)
      if entity_level == ENTITY_TYPE_DISTRICT
        '1' + state_fips[state.upcase] + entity_id.to_s.rjust(5, '0')
      elsif entity_level == ENTITY_TYPE_SCHOOL
        state_fips[state.upcase] + entity_id.to_s.rjust(5, '0')
      else
        state_fips[state.upcase]
      end
    end
  end
end
