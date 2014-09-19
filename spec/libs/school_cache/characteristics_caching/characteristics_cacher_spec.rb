require 'spec_helper'

describe CharacteristicsCaching::CharacteristicsCacher do
  let(:school) { FactoryGirl.build(:alameda_high_school) }
  let(:cacher) { CharacteristicsCaching::CharacteristicsCacher.new(school) }
  let(:result) {
    Hashie::Mash.new({
                         data_type_id: 1,
                         label: 'Planet of origin',
                         source: 'Jupiter Dept of Ed',
                         breakdown: 'Earthling',
                         subject: nil,
                         grade: 2,
                         year: 2010,
                         school_value: 10,
                         state_average: 20,
                         data_set_with_values: Hashie::Mash.new({ census_data_config_entry: nil})
                     })
  }
  let(:unconfigured_ethnicity_result) {
    Hashie::Mash.new({
                         data_type_id: :a,
                         label: 'Ethnicity',
                         source: 'Jupiter Dept of Ed',
                         breakdown: 'Earthling',
                         subject: nil,
                         grade: 2,
                         year: 2010,
                         school_value: 10,
                         state_average: 20,
                         data_set_with_values: Hashie::Mash.new({ has_config_entry?: nil})
                     })
  }
  let(:configured_characteristics_data_types) { {a: 1, b: 2, c: 3} }
  let(:result_hash) {
    {year: 2010,
     source: 'Jupiter Dept of Ed',
     grade: 2,
     school_value: 10,
     state_average: 20,
     breakdown: 'Earthling'}
  }
  let(:decorator) { Hashie::Mash.new(result) }
  let(:unconfigured_ethnicity_decorator) { Hashie::Mash.new(unconfigured_ethnicity_result) }
  let(:results_hash) { { 'Planet of origin' => [result_hash] } }

  describe '#build_hash_for_data_set' do
    it 'builds the correct hash' do
      expect(cacher.build_hash_for_data_set(result)).to eq(result_hash)
    end
  end

  describe '#build_hash_for_cache' do
    it 'builds the correct hash' do
      allow_any_instance_of(CharacteristicsCaching::CharacteristicsCacher).to receive(:query_results).and_return([decorator])
      expect(cacher.build_hash_for_cache).to eq(results_hash)
    end

    it 'does not build a hash for unconfigured breakdowns of configured data types' do
      allow_any_instance_of(CharacteristicsCaching::CharacteristicsCacher).to receive(:query_results).and_return([unconfigured_ethnicity_decorator])
      allow_any_instance_of(CharacteristicsCaching::Base).to receive(:configured_characteristics_data_types).and_return(configured_characteristics_data_types)
      expect(cacher.build_hash_for_cache).to eq({})
    end
  end

end

