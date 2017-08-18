module Feeds
  class DistrictDataBuilder < DataBuilder
    def initialize(state, data_type, school)
      super(state, data_type, school, ENTITY_TYPE_DISTRICT)
    end
  end
end