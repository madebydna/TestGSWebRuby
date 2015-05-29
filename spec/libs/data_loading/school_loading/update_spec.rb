require 'spec_helper'
require 'libs/data_loading/shared_examples_for_updates'

describe SchoolLoading::Update do

  required_update_keys = [:entity_id, :entity_state, :value, :member_id, :created]

  it_behaves_like 'an update', SchoolLoading::Update, required_update_keys

  let(:valid_update) {
    {
        action: :disable,
        created: '2013-05-04',
        entity_type: :school,
        entity_id: 23,
        entity_state: 'AK',
        member_id: 123,
        value: 34
    }
  }

  it 'should require data type' do
    expect { SchoolLoading::Update.new(nil, valid_update) }.to raise_error(/data_type/)
  end


end