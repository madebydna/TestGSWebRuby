require 'spec_helper'

describe CensusDataStateValue do
  let(:valid_attributes) {
    {
      data_set_id: 1,
      value_float: 1
    }
  }

  after { clean_models CensusDataStateValue }

  it 'should be able to be written to' do
    expect{ CensusDataStateValue.on_db(:ca).create(valid_attributes) }.not_to raise_error
  end
end
