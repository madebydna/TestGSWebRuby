require "spec_helper"

describe 'CollegeSuccess' do
  let(:school_cache_data_reader) { double("school_cache_data_reader") }
  subject(:college_success) do
    SchoolProfiles::CollegeSuccess.new(
       school_cache_data_reader: school_cache_data_reader
    )
  end

  it { is_expected.to respond_to(:props) }
  it { is_expected.to respond_to(:cs_component) }
  it { is_expected.to respond_to(:csa_award_winning_years) }

  let(:cca) { SchoolProfiles::CollegeReadiness::CHAR_CACHE_ACCESSORS }

  context '#cache_accessor' do
    let(:school) { double("school") }
    let(:school_cache_data_reader) { double("school_cache_data_reader") }
    subject(:college_success) do
      SchoolProfiles::CollegeSuccess.new(
        school_cache_data_reader: school_cache_data_reader
      )
    end

    it 'should return an array' do
      expect(subject.cs_component.cache_accessor).to be_an_instance_of(Array)
    end

    it 'should select different arrays when tab is different' do
      college_readiness_component = SchoolProfiles::CollegeReadinessComponent.new(
        'college_readiness', school_cache_data_reader
      )
      expect(subject).not_to eq(college_readiness_component.cache_accessor)
      college_success_component = SchoolProfiles::CollegeReadinessComponent.new(
        'college_success', school_cache_data_reader
      )
      expect(subject.cs_component.cache_accessor).to eq(college_success_component.cache_accessor)
    end
  end  

end