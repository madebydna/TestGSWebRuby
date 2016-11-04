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

  describe '#data_values' do
    before do
      allow(school_cache_data_reader).to receive(:school).and_return(school)
      allow(school).to receive(:state).and_return(:ca)
      allow(school).to receive(:id).and_return(1)
    end

    let (:sample_data) do
      {
          'Average SAT score' => [
              {
                  'breakdown' => 'All students',
                  'school_value' => 1600,
                  'state_average' => 1400
              }
          ],
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
              },
              {
                  'breakdown' => 'White',
                  'school_value' => 40,
                  'state_average' => 41
              }
          ],
          'Average ACT score' => [
              {
                  'breakdown' => 'All students',
                  'school_value' => 20,
                  'state_average' => 19,
                  'subject' => 'Reading'
              },
              {
                  'breakdown' => 'All students',
                  'school_value' => 25,
                  'state_average' => 24,
                  'subject' => 'All subjects'
              },
              {
                  'breakdown' => 'All students',
                  'school_value' => 30,
                  'state_average' => 29,
                  'subject' => 'Math'
              }
          ]
      }
    end

    it 'should return chosen data types if data present' do
      expect(school_cache_data_reader).to receive(:characteristics_data) do
        sample_data
      end.exactly(2).times
      expect(subject.data_values.size).to eq(3)
      data_points = subject.data_values.find {|item| item.label == 'Average SAT score' }
      expect(data_points).to be_present
      expect(data_points.score).to eq(1600)
      expect(data_points.state_average).to eq(1400)
      expect(data_points.range).to eq((600..2400))
    end

    it 'should pull from the "All students" breakdown' do
      expect(school_cache_data_reader).to receive(:characteristics_data).and_return(sample_data).once
      data_points = subject.data_values.find {|item| item.label == '4-year high school graduation rate' }
      expect(data_points).to be_present
      expect(data_points.score).to eq(50)
      expect(data_points.state_average).to eq(51)
    end

    it 'should pull from the "All subjects" subject' do
      expect(school_cache_data_reader).to receive(:characteristics_data).and_return(sample_data).once
      data_points = subject.data_values.find {|item| item.label == 'Average ACT score' }
      expect(data_points).to be_present
      expect(data_points.score).to eq(25)
      expect(data_points.state_average).to eq(24)
    end

    it 'should return empty array if no data' do
      expect(school_cache_data_reader).to receive(:characteristics_data).once
      expect(subject.data_values).to be_empty
    end
  end
end
