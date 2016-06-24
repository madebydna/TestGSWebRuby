module Feeds
  class SchoolDataBuilder < DataBuilder
    def initialize(state, data_type, school)
      super(state, data_type, school, ENTITY_TYPE_SCHOOL)
    end
  end
end