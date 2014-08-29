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
                     })
  }
  let(:result_hash) {
    {year: 2010,
     source: 'Jupiter Dept of Ed',
     grade: 2,
     school_value: 10,
     state_average: 20,
     breakdown: 'Earthling'}
  }
  let(:decorator) { Hashie::Mash.new(result_hash.merge(label: result.label)) }
  let(:results_hash) { { 'Planet of origin' => [result_hash] } }

  describe '#build_hash_for_data_set' do
    it 'builds the correct hash' do
      expect(cacher.build_hash_for_data_set(result)).to eq(result_hash)
    end
  end

  describe '$build_hash_for_cache' do
    it 'builds the correct hash' do
      allow_any_instance_of(CharacteristicsCaching::CharacteristicsCacher).to receive(:query_results).and_return([decorator])
      expect(cacher.build_hash_for_cache).to eq(results_hash)
    end
  end

end

