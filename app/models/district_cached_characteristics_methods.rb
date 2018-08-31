# frozen_string_literal: true

module DistrictCachedCharacteristicsMethods

  def enrollment
    #TODO 500-proof this
    cache_data['district_characteristics']['Enrollment'][0]['district_value']
  end

end