# frozen_string_literal: true

module StateCachedDistrictLargestMethods
  def largest_districts
    cache_data.fetch('district_largest', {})
  end

end
