require 'spec_helper'

describe CensusDataDistrictValue do
  let(:valid_attributes) {
    {
      district_id: 1,
      data_set_id: 1,
      value_float: 1
    }
  }

  after { clean_models CensusDataDistrictValue }

  it 'should not be read only' do
    expect{ CensusDataDistrictValue.on_db(:ca).create(valid_attributes) }.not_to raise_error
  end
end
