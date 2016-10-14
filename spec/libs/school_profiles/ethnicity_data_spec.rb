require "spec_helper"

describe SchoolProfiles::EthnicityData do
  let(:school) { double("school") }
  let(:school_cache_data_reader) { double("school_cache_data_reader") }
  subject(:ethnicity_data) do
    SchoolProfiles::EthnicityData.new(
      school_cache_data_reader: school_cache_data_reader
    )
  end
  it { is_expected.to respond_to(:data_values) }

  describe '#data_values' do
    it 'should return chosen data types if data present' do
      # TODO: rewrite spec to increase specificity
      expect(school_cache_data_reader).to receive(:ethnicity_data) do
        {
          'Ethnicity' => [
            {
              'breakdown' => 'Asian',
              'school_value' => 60
            },
            {
              'breakdown' => 'Black',
              'school_value' => 50
            }
          ]
        }
      end.exactly(3).times
      expect(subject.data_values.size).to eq(1)
      expect(subject.data_values.keys.first).to eq('Ethnicity')
      expect(subject.data_values["Ethnicity"].first['school_value']).to eq(60)
    end

    it 'should return nil' do
      expect(school_cache_data_reader).to receive(:ethnicity_data).once
      expect(subject.data_values).to eq(nil)
    end
  end
end
