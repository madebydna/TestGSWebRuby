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

    describe 'With sample data' do
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

      let (:gsdata_sample_data) do
        {
            'Percentage of students passing 1 or more AP exams grades 9-12' => [
                {
                    'breakdowns' => 'Hispanic,Male',
                    'district_value' => '47.62',
                    'school_value' => '58',
                    'source_name' => 'Civil Rights Data Collection',
                    'source_year' => 2014,
                    'state_value' => '49.78'
                }, {
                    'district_value' => '58.47',
                    'school_value' => '61',
                    'source_name' => 'Civil Rights Data Collection',
                    'source_year' => 2014,
                    'state_value' => '60.32'
                }
            ]
        }
      end

      before do
        expect(school_cache_data_reader).to receive(:characteristics_data).and_return(sample_data)
        expect(school_cache_data_reader).to receive(:gsdata_data).and_return(gsdata_sample_data)
      end

      it 'should return chosen data types if data present' do
        data_values = subject.data_values
        expect(data_values.size).to eq(4)
        data_points = data_values.find {|item| item.label == 'Average SAT score' }
        expect(data_points).to be_present
        expect(data_points.score).to eq(1600)
        expect(data_points.state_average).to eq(1400)
        expect(data_points.range).to eq((600..2400))
      end

      it 'should pull from the "All students" breakdown for characteristics' do
        data_points = subject.data_values.find {|item| item.label == '4-year high school graduation rate' }
        puts data_points.score.inspect
        expect(data_points).to be_present
        expect(data_points.score).to eq(50)
        expect(data_points.state_average).to eq(51)
      end

      it 'should pull from the null breakdown for gsdata' do
        data_points = subject.data_values.find {|item| item.label == 'Percentage of students passing 1 or more AP exams grades 9-12' }
        expect(data_points).to be_present
        expect(data_points.score).to eq('61')
        expect(data_points.state_average).to eq('60.32')
      end

      it 'should pull from the "All subjects" subject' do
        data_points = subject.data_values.find {|item| item.label == 'Average ACT score' }
        expect(data_points).to be_present
        expect(data_points.score).to eq(25)
        expect(data_points.state_average).to eq(24)
      end

      it 'should return chosen data types in configured order' do
        ordered_data_types = subject.included_data_types
        data_value_labels = subject.data_values.map(&:label)

        # start with full set of ordered data types, then remove items
        # that are not in the resulting data_value_labels. Expression should
        # yield an array that is in same order as data_value_labels
        expect(ordered_data_types & data_value_labels).to eq(data_value_labels)
      end
    end

    it 'should return empty array if no data' do
      expect(school_cache_data_reader).to receive(:characteristics_data).and_return({})
      expect(school_cache_data_reader).to receive(:gsdata_data).and_return({})
      expect(subject.data_values).to be_empty
    end
  end

  describe '#ordered_data_types' do
    it 'should return configured data types in correct order' do
      config = [
        { :data_key => 'a' }, { :data_key => 'b' }, { :data_key => 'c' }
      ].shuffle
      stub_const('SchoolProfiles::CollegeReadiness::CHAR_CACHE_ACCESSORS', config)
      expect(subject.included_data_types).to eq(config.map { |o| o[:data_key] } )
    end
  end
end
