require 'spec_helper'

describe CharacteristicsCaching::Validation do
  let(:multi_source_ethnicity_data) {
    {'Ethnicity' =>
         [{year: 2012,
           source: 'NCES',
           breakdown: 'White',
           school_value: 65.38,
           state_average: 1.05},
          {year: 2012,
           source: 'OSSE',
           breakdown: 'Asian',
           school_value: 4.86,
           state_average: 12.15},
          {year: 2012,
           source: 'OSSE',
           breakdown: 'Hawaiian Native/Pacific Islander',
           school_value: 0.0,
           state_average: 0.0}]}
  }

  let(:low_sum_ethnicity_data) {
    {'Ethnicity' =>
         [{year: 2012,
           source: 'NCES',
           breakdown: 'White',
           state_average: 1.05},
          {year: 2012,
           source: 'NCES',
           breakdown: 'Asian',
           school_value: 4.86,
           state_average: 12.15},
          {year: 2012,
           source: 'NCES',
           breakdown: 'Black',
           school_value: 14.86,
           state_average: 1.15},
          {year: 2012,
           source: 'NCES',
           breakdown: 'Hispanic',
           state_average: 13.0},
          {year: 2012,
           source: 'NCES',
           breakdown: 'Two or more races',
           school_value: 3.32,
           state_average: 56.96},
          {year: 2012,
           source: 'NCES',
           breakdown: 'American Indian/Alaska Native',
           school_value: 0.0,
           state_average: 0.0},
          {year: 2012,
           source: 'NCES',
           breakdown: 'Hawaiian Native/Pacific Islander',
           school_value: 0.0,
           state_average: 0.0}]}
  }

  let(:data_with_empty_values) {
    {
      'Ethnicity' => [
        { year: 2012,
          source: 'NCES',
          breakdown: 'White',
          school_value: 65.38,
          state_average: 1.05
        },
        { year: 2012,
          source: 'OSSE',
          breakdown: 'Asian',
          school_value: 4.86,
          state_average: 12.15},
        {
          year: 2012,
          source: 'OSSE',
          breakdown: 'Hawaiian Native/Pacific Islander',
          school_value: 0.0,
          state_average: 0.0
        }
      ],
      'Sat percent participation' => []
    }
  }


  let(:school) { FactoryGirl.build(:alameda_high_school) }
  let(:cacher) { CharacteristicsCaching::CharacteristicsCacher.new(school) }

  context 'Ethnicity data validation' do

    it 'should remove all but the best source - the one with the highest percentage' do
      validated_data = cacher.validate!(multi_source_ethnicity_data)
      validated_data.each do |ethnicity|
        expect(ethnicity[:source]).to eq('NCES')
      end
    end

    it 'should reject ethnicity data that does not add up to a reasonable percentage' do
      validated_data = cacher.validate!(low_sum_ethnicity_data)
      expect(validated_data).to eq({})
    end
  end

  describe '#validate_format!' do
    before { cacher.instance_variable_set(:@characteristics, data_with_empty_values) }
    it 'should remove key/value pairs that have an empty array as a value' do
      empty_key_value = data_with_empty_values.select {|k,v| v.empty?}
      expect(data_with_empty_values).to include(empty_key_value)
      cacher.validate_format!
      validated_data = cacher.instance_variable_get(:@characteristics)
      expect(validated_data).to_not include(empty_key_value)
    end
    it 'should not remove key/value pairs that have values' do
      data_with_key_values = data_with_empty_values.select {|k,v| v.present?}
      expect(data_with_empty_values).to include(data_with_key_values)
      cacher.validate_format!
      validated_data = cacher.instance_variable_get(:@characteristics)
      expect(validated_data).to include(data_with_key_values)
    end
  end
end