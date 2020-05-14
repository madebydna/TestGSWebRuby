# frozen_string_literal: true

module DistrictCachedDistanceLearningMethods
  def distance_learning
    @_distance_learning ||= cache_data.fetch('crpe', {})
  end
end