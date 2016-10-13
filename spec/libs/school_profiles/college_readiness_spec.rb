require "spec_helper"

describe SchoolProfiles::CollegeReadiness do
  let(:school) { double("school") }
  let(:school_cache_data_reader) { double("school_cache_data_reader") }
  subject(:college_readiness) do
    SchoolProfiles::CollegeReadiness.new(
      school_cache_data_reader: school_cache_data_reader
    )
  end
  it { is_expected.to respond_to(:rating) }
  it { is_expected.to respond_to(:data_values) }

  describe "::RatingLabelMap" do
    it "should have 10 items" do
      expect(SchoolProfiles::CollegeReadiness::RATING_LABEL_MAP.count).to eq(10)
    end
  end

  describe "#rating_label" do
    SchoolProfiles::CollegeReadiness::RATING_LABEL_MAP
      .each do |rating, label|
      it "returns correct #{label} for rating score: #{rating}" do
        allow(subject).to receive(:rating).and_return(rating.to_i)
        expect(subject.rating_label).to eq(SchoolProfiles::CollegeReadiness::RATING_LABEL_MAP[rating])
      end
    end
  end

  describe '#data_values' do
    it 'should return chosen data types if data present' do
      expect(school_cache_data_reader).to receive(:characteristics_data) do
        {
          '4-year high school graduation rate' => [
            {
              'breakdown' => 'Asian',
              'school_value' => 60,
              'state_average' => 61
            },
            {
              'breakdown' => 'All students',
              'school_value' => 50,
              'state_average' => 51
            }
          ]
        }
      end.exactly(4).times
      expect(subject.data_values.size).to eq(1)
      expect(subject.data_values.first.label).to eq('4-year high school graduation rate')
      expect(subject.data_values.first.score).to eq(50)
      expect(subject.data_values.first.state_average).to eq(51)
    end

    it 'should return empty array if no data' do
      expect(school_cache_data_reader).to receive(:characteristics_data).once
      expect(subject.data_values).to be_empty
    end
  end
end
