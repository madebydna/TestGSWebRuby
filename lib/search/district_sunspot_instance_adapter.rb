# frozen_string_literal: true

module Search
  class DistrictSunspotInstanceAdapter < Sunspot::Adapters::InstanceAdapter
    def id
      DistrictDocument.unique_key(@instance.state, @instance.id)
    end
  end
end
