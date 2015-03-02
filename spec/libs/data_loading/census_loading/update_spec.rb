require 'spec_helper'
require 'libs/data_loading/shared_examples_for_updates'

describe CensusLoading::Update do

  required_update_keys = [:entity_type, :entity_id, :entity_state, :value]

  it_behaves_like 'an update', CensusLoading::Update, required_update_keys

  let(:data_type) { FactoryGirl.build(:census_data_type) }
  let(:sourceless_update) {
    {
        entity_state: 'CA',
        entity_type: :school,
        entity_id: 1,
        value: 23,
    }
  }

  context 'source' do
    let(:default_source) { 'Manually entered by a school official' }
    let(:blank_source_update) {
      {
          entity_state: 'CA',
          entity_type: :school,
          entity_id: 1,
          value: 23,
          source: '     '
      }
    }
    let(:sourceful_update) {
      {
          entity_state: 'CA',
          entity_type: :school,
          entity_id: 1,
          value: 23,
          source: 'Dept of Fake Sources'
      }
    }

    it 'should default to Manually entered by a school official' do
      census_update = CensusLoading::Update.new(data_type, sourceless_update)
      expect(census_update.source).to eq(default_source)
    end

    it 'should use the default source for blank, non-nill sources' do
      census_update = CensusLoading::Update.new(data_type, blank_source_update)
      expect(census_update.source).to eq(default_source)
    end

    it 'should use the source if given one' do
      census_update = CensusLoading::Update.new(data_type, sourceful_update)
      expect(census_update.source).to eq('Dept of Fake Sources')
    end
  end


  context '#census_description_attributes' do
    it 'should be memoized' do
      census_update = CensusLoading::Update.new(data_type, sourceless_update)
      expect(census_update).to memoize(:census_description_attributes)
    end
  end


end