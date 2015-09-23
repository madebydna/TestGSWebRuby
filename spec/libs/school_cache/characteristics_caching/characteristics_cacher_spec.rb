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
                         breakdown_id: 12,
                         subject_id: nil,
                         grade: 2,
                         year: 2010,
                         school_value: 10,
                         state_average: 20,
                         data_set_with_values: Hashie::Mash.new({ census_data_config_entry: nil})
                     })
  }
  let(:result_for_test_scores) {
    Hashie::Mash.new({
                         data_type_id: 2,
                         label: 'Planet of origin',
                         source: 'Jupiter Dept of Ed',
                         breakdown: 'Earthling',
                         breakdown_id: nil,
                         subject_id: 5,
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
                         breakdown_id: 12,
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
    {
      year: 2010,
      source: 'Jupiter Dept of Ed',
      grade: 2,
      school_value: 10,
      state_average: 20,
      breakdown: 'Earthling',
      original_breakdown: 'Earthling',
    }
  }
  let(:decorator) { Hashie::Mash.new(result) }
  let(:unconfigured_ethnicity_decorator) { Hashie::Mash.new(unconfigured_ethnicity_result) }
  let(:results_hash) { { 'Planet of origin' => [result_hash] } }

  let(:all_results) do
    [
      Hashie::Mash.new({breakdown_id: 12, subject_id: nil, year: 2010, school_value: 10, state_value: 20, data_type_id: 1}),
      Hashie::Mash.new({breakdown_id: 12, subject_id: nil, year: 2011, school_value: 20, state_value: 20, data_type_id: 1}),
      Hashie::Mash.new({breakdown_id: 13, subject_id: nil, year: 2012, school_value: 20, state_value: 20, data_type_id: 1}),
      Hashie::Mash.new({breakdown_id: 14, subject_id: nil, year: 2013, school_value: 20, state_value: 20, data_type_id: 1}),
      Hashie::Mash.new({breakdown_id: 12, subject_id: nil, year: 2000, school_value: nil, state_value: nil, data_type_id: 1}),
      Hashie::Mash.new({breakdown_id: nil, subject_id: 5, year: 2013, school_value: 50, state_value: 40, data_type_id: 2}),
      Hashie::Mash.new({breakdown_id: nil, subject_id: 5, year: 2014, school_value: 70, state_value: 30, data_type_id: 2}),
      Hashie::Mash.new({breakdown_id: nil, subject_id: 6, year: 2010, school_value: 70, state_value: 30, data_type_id: 2}),
      Hashie::Mash.new({breakdown_id: nil, subject_id: 7, year: 2011, school_value: 70, state_value: 30, data_type_id: 2}),
      Hashie::Mash.new({breakdown_id: nil, subject_id: 5, year: 2000, school_value: nil, state_value: nil, data_type_id: 2}),
    ]
  end

  let(:historical_data_keys) { [ :school_value_2010, :school_value_2011, :state_average_2010, :state_average_2011 ] }
  let(:wrong_historical_data_keys) { [ :school_value_2012, :school_value_2013, :state_average_2012, :state_average_2013 ] }
  let(:valueless_historical_data_keys) { [ :school_value_2000 ] }
  let(:historical_data_keys_for_test_scores) { [ :school_value_2013, :school_value_2014, :state_average_2013, :state_average_2014 ] }
  let(:wrong_historical_data_keys_for_test_scores) { [ :school_value_2010, :school_value_2011, :state_average_2010, :state_average_2011 ] }
  let(:valueless_historical_data_keys_for_test_scores) { [ :school_value_2000 ] }


  describe '#build_hash_for_data_set' do
    it 'builds the correct hash' do
      expect(cacher.build_hash_for_data_set(result)).to eq(result_hash)
    end

    context 'when there is breakdown data for multiple years' do
      before { cacher.instance_variable_set(:@all_results, all_results) }
      it 'should save multiple years of data' do
        expect(cacher.build_hash_for_data_set(result).keys).to include(*historical_data_keys)
      end

      it 'should grab data based on breakdown id and not subject id' do
        expect(cacher.build_hash_for_data_set(result).keys).not_to include(*wrong_historical_data_keys)
      end

      it 'should not set historical data if the values are empty' do
        expect(cacher.build_hash_for_data_set(result_for_test_scores).keys).not_to include(*valueless_historical_data_keys)
      end
    end

    context 'when there is test score data for multiple years' do
      before { cacher.instance_variable_set(:@all_results, all_results) }
      it 'should save multiple years of data' do
        expect(cacher.build_hash_for_data_set(result_for_test_scores).keys).to include(*historical_data_keys_for_test_scores)
      end
      
      it 'should grab data based on subject id and not breakdown id' do
        expect(cacher.build_hash_for_data_set(result_for_test_scores).keys).not_to include(*wrong_historical_data_keys_for_test_scores)
      end

      it 'should not set historical data if the values are empty' do
        expect(cacher.build_hash_for_data_set(result_for_test_scores).keys).not_to include(*valueless_historical_data_keys_for_test_scores)
      end
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

