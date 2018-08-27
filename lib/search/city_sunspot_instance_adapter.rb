# frozen_string_literal: true

module Search
  class CitySunspotInstanceAdapter < Sunspot::Adapters::InstanceAdapter
    def id
      CityDocument.unique_key(@instance.id)
    end
  end
end
