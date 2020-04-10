require 'spec_helper'

describe DistrictCacheResults do
  let(:district) do
    instance_double(DistrictRecord, state: "ca", district_id: 1)
  end

end