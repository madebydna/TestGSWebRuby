require "spec_helper"

describe 'CollegeReadinessComponent' do
  let(:school) { double("school") }
  let(:school_cache_data_reader) { double("school_cache_data_reader") }
  subject(:college_readiness) do
    ::SchoolProfiles::CollegeReadinessComponent.new(
      'college_readiness', school_cache_data_reader
    )
  end
  it { is_expected.to respond_to(:rating) }
  it { is_expected.to respond_to(:data_values) }

  let(:cca) { SchoolProfiles::CollegeReadiness::CHAR_CACHE_ACCESSORS }

  context '#cache_accessor' do
    let(:school) { double("school") }
    let(:school_cache_data_reader) { double("school_cache_data_reader") }
    subject(:college_readiness) do
      ::SchoolProfiles::CollegeReadinessComponent.new(
        'college_readiness', school_cache_data_reader
      )
    end
    it 'should return an array' do
      expect(subject.cache_accessor).to be_an_instance_of(Array)
    end

    it 'should select different arrays when tab is different' do
      college_success_component = ::SchoolProfiles::CollegeReadinessComponent.new(
        'college_success', school_cache_data_reader
      )
      expect(subject.cache_accessor).not_to eq(college_success_component.cache_accessor)
    end
  end

  describe '#data_values' do
    before do
      allow(school_cache_data_reader).to receive(:school).and_return(school)
      allow(school).to receive(:state).and_return(:ca)
      allow(school).to receive(:id).and_return(1)
      allow(school_cache_data_reader).to receive(:decorated_gsdata_datas).and_return({})
    end

    describe 'With sample data' do
      let (:sample_data) do
        {
            'Average SAT score' => [
                {
                    'breakdown' => 'All students',
                    'school_value' => 1600,
                    'state_average' => 1400,
                    'year' => 2016
                }
            ],
            '4-year high school graduation rate' => [
                {
                    'breakdown' => 'Asian',
                    'school_value' => 60,
                    'state_average' => 61,
                    'year' => 2016
                },
                {
                    'breakdown' => 'All students',
                    'school_value' => 50,
                    'state_average' => 51,
                    'year' => 2016
                },
                {
                    'breakdown' => 'White',
                    'school_value' => 40,
                    'state_average' => 41,
                    'year' => 2016
                }
            ],
            'Average ACT score' => [
                {
                    'breakdown' => 'All students',
                    'school_value' => 20,
                    'school_value_2016' => 20,
                    'state_average' => 19,
                    'year' => 2016,
                    'subject' => 'Reading'
                },
                {
                    'breakdown' => 'All students',
                    'school_value' => 25,
                    'school_value_2016' => 25,
                    'state_average' => 24,
                    'year' => 2016,
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
          'Percentage of students passing 1 or more AP exams grades 9-12' => GsdataCaching::GsDataValue.from_array_of_hashes([
                {
                    'data_type' => 'Percentage of students passing 1 or more AP exams grades 9-12',
                    'breakdowns' => 'Hispanic,Male',
                    'district_value' => '47.62',
                    'school_value' => '58',
                    'source_name' => 'Civil Rights Data Collection',
                    'source_year' => 2014,
                    'state_value' => '49.78'
                }, {
                    'data_type' => 'Percentage of students passing 1 or more AP exams grades 9-12',
                    'district_value' => '58.47',
                    'school_value' => '61',
                    'source_name' => 'Civil Rights Data Collection',
                    'source_year' => 2014,
                    'state_value' => '60.32'
                }
            ])
        }
      end

      before do
        expect(school_cache_data_reader).to receive(:metrics_data).and_return(sample_data)
        allow(school_cache_data_reader).to receive(:decorated_gsdata_datas).and_return(gsdata_sample_data)
        allow(subject).to receive(:new_sat?).and_return(false)
      end

      it 'should return chosen data types if data present' do
        data_values = subject.data_values
        expect(data_values.size).to eq(4)
        data_points = data_values.find {|item| item.label == 'Average SAT score' }
        expect(data_points).to be_present
        expect(data_points.score).to eq(1600)
        expect(data_points.state_average).to eq(1400)
        expect(data_points.range).to eq(SchoolProfiles::CollegeReadiness::OLD_SAT_RANGE)
      end

      it 'should pull from the "All students" breakdown for metrics' do
        data_points = subject.data_values.find {|item| item.label == '4-year high school graduation rate' }
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

    describe 'With mismatching average SAT score / SAT percent participation' do
      let (:sample_data) do
        {
          'Average SAT score' => [
            {
              'breakdown' => 'All students',
              'subject' => 'All subjects',
              'school_value' => 1600,
              'year' => 2015,
              'state_average' => 1400
            }
          ],
          'SAT percent participation' => [
            {
              'breakdown' => 'All students',
              'subject' => 'All subjects',
              'school_value' => 1600,
              'year' => 2016,
              'state_average' => 1400
            }
          ]
        }
      end

      before do
        expect(school_cache_data_reader).to receive(:metrics_data).and_return(sample_data)
        allow(school_cache_data_reader).to receive(:gsdata_data).and_return({})
      end

      it 'should set school SAT score to nil' do
        data_points = subject.data_values.find {|item| item.label == 'Average SAT score' }
        expect(data_points).to_not be_present
      end

    end

    it 'should return empty array if no data' do
      expect(school_cache_data_reader).to receive(:metrics_data).and_return({})
      allow(school_cache_data_reader).to receive(:gsdata_data).and_return({})
      expect(subject.data_values).to be_empty
    end

    describe 'SAT ranges' do
      let (:sample_data) do
        {
            'Average SAT score' => [
                {
                    'breakdown' => 'All students',
                    'subject' => 'All subjects',
                    'school_value' => 1400,
                    'year' => 2016,
                    'state_average' => 1200
                }
            ]
        }
      end

      before do
        expect(school_cache_data_reader).to receive(:metrics_data).and_return(sample_data)
        allow(school_cache_data_reader).to receive(:gsdata_data).and_return({})
      end

      describe 'In states with new ranges' do
        [:ca, :mi, :nj, :ct, :co].each do |state|
          describe "like #{state}" do
            before do
              allow(school).to receive(:state).and_return(state)
            end

            subject { college_readiness.data_values.find { |item| item.label == 'Average SAT score' }.range }

            it { is_expected.to eq(SchoolProfiles::CollegeReadiness::NEW_SAT_RANGE) }
          end
        end
      end

      describe 'In states with old ranges' do
        [:ak, :de, :ny, :pa, :tx, :wi].each do |state|
          describe "like #{state}" do
            before do
              allow(school).to receive(:state).and_return(state)
            end

            subject { college_readiness.data_values.find { |item| item.label == 'Average SAT score' }.range }

            it { is_expected.to eq(SchoolProfiles::CollegeReadiness::OLD_SAT_RANGE) }
          end
        end
      end
    end
  end

  describe '#sources_for_view' do
    subject { college_readiness.sources_text(hash) }
    let(:hash) { OpenStruct.new(valid_hash) }
    let(:valid_hash) do
      {
        'data_type' => 'foo',
        'description' => 'description',
        'source' => 'foo',
        'year' => 2014
      }
    end

    it { is_expected.to be_a(String) }

    context 'with missing source' do
      let(:hash) { valid_hash.except('source') }
      it { is_expected.to be_a(String) }
    end
    context 'with missing year' do
      let(:hash) { valid_hash.except('year') }
      it { is_expected.to be_a(String) }
    end
  end

  describe '#included_data_types' do
    it 'should return configured data types in correct order' do
      config = [
        { :data_key => 'a' }, { :data_key => 'b' }, { :data_key => 'c' }
      ].shuffle
      allow(subject).to receive(:cache_accessor).and_return config
      expect(subject.included_data_types).to eq(config.map { |o| o[:data_key] })
    end
  end

  describe '#with_school_values' do
    let (:sample_data) do
      [
          {school_value: 15},
          {state_value: 15},
          {sChool_value: 15},
          {school_value: nil},
          {school_value: 0}
      ].map(&:stringify_keys)
    end

    let (:expected_outcome) do
      [
          {school_value: 15},
          {school_value: 0}
      ].map(&:stringify_keys)
    end

    it 'includes only hashes with the key school_value set to a non-nil value' do
      expect(sample_data.select(&subject.send(:with_school_values))).to contain_exactly(*expected_outcome)
    end
  end
end

describe 'CollegeSuccessComponent' do
  let(:school) { double("school") }
  let(:school_cache_data_reader) { double("school_cache_data_reader") }
  let(:cr_rating) { 5 }
  subject(:college_readiness) do
    ::SchoolProfiles::CollegeReadinessComponent.new(
      'college_success', school_cache_data_reader
    )
  end
  let (:remediation_sample_data) do
    {
      "Percent Needing Remediation for College" => [
        {
          "breakdown"=>"All students",
          "created"=>"2017-04-19T23:20:49-07:00",
          "school_value"=>16.0,
          "source"=>"Oklahoma State Regents for Higher Education",
          "state_average"=>35.7,
          "subject"=>"Math",
          "year"=>2015
        }, {
          "breakdown"=>"All students",
          "created"=>"2017-04-19T23:20:49-07:00",
          "school_value"=>5.3,
          "source"=>"Oklahoma State Regents for Higher Education",
          "state_average"=>8.3,
          "subject"=>"Reading",
          "year"=>2015
        }, {"breakdown"=>"All students",
            "created"=>"2017-04-19T23:20:49-07:00",
            "school_value"=>1.8,
            "source"=>"Oklahoma State Regents for Higher Education",
            "state_average"=>15.7,
            "subject"=>"English",
            "year"=>2015
        }, {"breakdown"=>"All students",
            "created"=>"2017-04-19T23:20:48-07:00",
            "school_value"=>0.0,
            "source"=>"Oklahoma State Regents for Higher Education",
            "state_average"=>1.1,
            "subject"=>"Science",
            "year"=>2014
        }
      ]
    }
  end

  before do
    allow(school_cache_data_reader).to receive(:school).and_return(school)
    allow(school).to receive(:state).and_return(:ca)
    allow(school).to receive(:id).and_return(1)
    allow(school_cache_data_reader).to receive(:metrics_data).and_return(remediation_sample_data)
    allow(school_cache_data_reader).to receive(:gsdata_data).and_return({})
    allow(school_cache_data_reader).to receive(:decorated_gsdata_datas).and_return({})
    allow(school_cache_data_reader).to receive(:college_readiness_rating).and_return(cr_rating)
  end

  let(:data_points) {subject.data_values}
  describe 'With remediation data' do
    it 'should return RatingScoreItems for each remediation data point' do
      expect(data_points).to be_present
      expect(data_points.all? {|dp| dp.is_a?(SchoolProfiles::RatingScoreItem)}).to be_truthy
    end

    it 'should include info text' do
      info_text_blank = data_points.any? {|dp| dp.info_text.blank?}
      expect(info_text_blank).to be_falsey
    end

    it 'should not include data from before the cutoff year' do
      # remediation_sample_data includes a data point from 2014, which is before the current cutoff.  That data point
      # should be filtered out of data_values
      cutoff = SchoolProfiles::CollegeReadiness::DATA_CUTOFF_YEAR
      before_cutoff_year = data_points.any? {|dp| dp.year.to_i < cutoff}
      expect(before_cutoff_year).to be_falsey
    end

    it 'should have a well-formatted label' do
      all_formatted = data_points.none? {|dp| dp.label.match(/Graduates needing (Math|English|Science|Reading) remediation in college/).nil?}
      expect(all_formatted).to be_truthy
    end
  end

  describe '#narration' do
    subject { college_readiness.narration }

    context 'when no rating' do
      let(:cr_rating) { nil }
      it 'should still delegate to college_success_narration' do
        expect(college_readiness).to receive(:college_success_narration)
        subject
      end
    end

    it 'should delegate to college_success_narration' do
      expect(college_readiness).to receive(:college_success_narration)
      subject
    end
  end

  describe '#college_success_narration' do
    subject { college_readiness.college_success_narration }

    before { allow(college_readiness).to receive(:default_college_success_narration).and_return('default') }

    context 'when missing a state average in any value' do
      before do
        remediation_sample_data['Percent Needing Remediation for College'].first.delete('state_average')
      end

      it 'returns the default narration' do
        expect(subject).to eq('default')
      end
    end

    it 'returns default narration if it cannot generate narrations' do
      expect(college_readiness).to receive(:narration_for_value).and_return(->(_) { nil }).once
      expect(subject).to eq('default')
    end

    it 'returns auto-narration if all goes well' do
      expect(college_readiness).to receive(:narration_for_value).and_return(->(_) { 'narration' }).once
      expect(subject).to_not eq('default')
    end
  end

  describe '#narration_for_value' do
    let(:value) { OpenStruct.new(data_type: 'Graduating seniors pursuing 4 year college/university', school_value: 38.5, state_average: 34.9) }
    subject { college_readiness.narration_for_value.call(value) }

    context 'for regular data' do
      it 'should detect above average' do
        expect(subject).to include('above average')
      end

      it 'should detect about average' do
        value.school_value = 36.6
        expect(subject).to include('about average')
      end

      it 'should detect below average' do
        value.school_value = 32.5
        expect(subject).to include('below average')
      end
    end

    context 'for persistence data' do
      before { value.data_type = 'Percent Enrolled in College and Returned for a Second Year' }
      it 'should detect higher' do
        expect(subject).to include('higher')
      end

      it 'should detect about average' do
        value.school_value = 36.6
        expect(subject).to include('about average')
      end

      it 'should detect lower' do
        value.school_value = 32.5
        expect(subject).to include('lower')
      end
    end
  end
end
