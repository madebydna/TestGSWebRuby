# frozen_string_literal: true

module Search
  class SchoolSunspotInstanceAdapter < Sunspot::Adapters::InstanceAdapter
    def id
      SchoolDocument.unique_key(@instance.state, @instance.school_id)
    end
  end
end
