require "spec_helper"

describe SchoolProfiles::TestScores do
  let(:school) { double("school", state: 'ca') }
  let(:school_cache_data_reader) { double("school_cache_data_reader") }

  subject(:hero) do
    SchoolProfiles::TestScores.new(
      school,
      school_cache_data_reader: school_cache_data_reader
    )
  end

  it { is_expected.to respond_to(:rating) }
  it { is_expected.to respond_to(:subject_scores) }
  it { is_expected.to respond_to(:flags_for_sources) }

  let(:test_scores) {
    [
      OpenStruct.new(
        description: 'Random School',
        flags: [],
        grade: 'All'
      )
    ]
  }

  describe '#visible' do
    state_without_standrized_testing = SchoolProfiles::TestScores::STATES_WITHOUT_HS_STANDARDIZED_TESTS.sample
    state_with_testing = (States.abbreviations - SchoolProfiles::TestScores::STATES_WITHOUT_HS_STANDARDIZED_TESTS).sample

    it 'should return false if test scores is not present' do
      allow(subject).to receive(:subject_scores).and_return([])
      expect(subject.visible?).to be_falsey
    end

    it 'should have a list of states without standarized testing' do
      expect {  SchoolProfiles::TestScores::STATES_WITHOUT_HS_STANDARDIZED_TESTS }.to_not raise_error
      expect(SchoolProfiles::TestScores::STATES_WITHOUT_HS_STANDARDIZED_TESTS).to eq(%w(al ct de il mt nh pa ri wv))
    end

    it 'should return true if test scores are present' do
      allow(subject).to receive(:subject_scores).and_return(test_scores)
      expect(subject.visible?).to be_truthy
    end

    [
      [state_without_standrized_testing, false, true, true],
      [state_without_standrized_testing, false, false, false],
      [state_without_standrized_testing, true, true, false],
      [state_without_standrized_testing, true, false, false],
      [state_with_testing, false, false, false],
      [state_with_testing, false, true, true],
      [state_with_testing, true, false, false],
      [state_with_testing, true, true, true],
    ].each do |(state, is_high_school, test_scores, result)|
      context "State:#{state}, high_school?: #{is_high_school}, Test_scores?: #{test_scores}, Expect_Result: #{result}" do
        let(:school) { double("school", state: state) }
        let(:school_cache_data_reader) { double("school_cache_data_reader") }
        subject do
          SchoolProfiles::TestScores.new(
            school,
            school_cache_data_reader: school_cache_data_reader
          )
        end

        it do
          allow(subject).to receive(:subject_scores).and_return(test_scores ? [double("test_scores")] : [])
          allow(school).to receive(:high_school?).and_return(is_high_school)

          expect(subject.visible?).to eq(result)
        end

      end
    end


  end
end


