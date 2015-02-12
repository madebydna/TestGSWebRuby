require 'spec_helper'
require 'libs/data_loading/shared_examples_for_updates'

describe CensusLoading::Update do

  required_update_keys = [:entity_type, :entity_id, :entity_state, :value]

  it_behaves_like 'an update', CensusLoading::Update, required_update_keys

  context 'source' do

    let(:data_type) { FactoryGirl.build(:census_data_type) }
    let(:sourceless_update) {
      {
          entity_state: 'CA',
          entity_type: :school,
          entity_id: 1,
          value: 23,
      }
    }
    let(:sourceless_census_update) { CensusLoading::Update.new(data_type, sourceless_update) }

    it 'should default to Manually entered by a school official' do
      default_source = 'Manually entered by a school official'
      expect(sourceless_census_update.source).to eq(default_source)
    end
  end


end