require "spec_helper"

describe 'SchoolProfiles::CollegeSuccess' do
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

  context '#csa_props' do
    let(:school) { double("school") }
    let(:school2) { double("school") }
    let(:csa_winner) do 
      hash = { 
        :csa_badge? => true,
        :csa_awards => [
          {"breakdowns"=>"non-frl award winning school", "school_value"=>"1", "source_date_valid"=>"20180101 00:00:00", "source_name"=>"GreatSchools"},
          {"breakdowns"=>"non-frl award winning school", "school_value"=>"1", "source_date_valid"=>"20190101 00:00:00", "source_name"=>"GreatSchools", "grade"=>"All"}
        ]
      }
      double("school_cache_data_reader", hash )
    end
    let(:multiple_csa_winner) do 
      hash = { 
        :csa_badge? => true,
        :csa_awards => [
          {"breakdowns"=>"non-frl award winning school", "school_value"=>"1", "source_date_valid"=>"20180101 00:00:00", "source_name"=>"GreatSchools"},
          {"breakdowns"=>"non-frl award winning school", "school_value"=>"1", "source_date_valid"=>"20190101 00:00:00", "source_name"=>"GreatSchools", "grade"=>"All"},
          {"breakdowns"=>"non-frl award winning school", "school_value"=>"1", "source_date_valid"=>"20200101 00:00:00", "source_name"=>"GreatSchools", "grade"=>"All"}
        ]
      }
      double("school_cache_data_reader", hash )
    end

    let(:not_a_csa_winner) { double("school_cache_data_reader", :csa_badge? => false) }

    let(:non_winning_college_success) { SchoolProfiles::CollegeSuccess.new(
        school_cache_data_reader: not_a_csa_winner
    )}
    let(:college_success) { SchoolProfiles::CollegeSuccess.new(
        school_cache_data_reader: csa_winner
    )}
    let(:multiple_college_success) { SchoolProfiles::CollegeSuccess.new(
        school_cache_data_reader: multiple_csa_winner
    )}

    before do
      allow(csa_winner).to receive(:school).and_return(school)
      allow(multiple_csa_winner).to receive(:school).and_return(school2)
      allow(school).to receive(:state).and_return('ar')
      allow(school2).to receive(:state).and_return('nj')
    end

    it 'should return an empty hash when it is not a winner' do
      expect(non_winning_college_success.csa_props).to eq({})
    end
    
    it 'should return the correct csa award winnings years' do
      expect(college_success.csa_award_winning_years).to eq([2018, 2019])
      expect(multiple_college_success.csa_award_winning_years).to eq([2018, 2019, 2020])
    end

    it 'should return html syntax representing the correct years and state page urls' do
      expect(college_success.csa_props[:csa_badge].include?('2018 and 2019')).to eq(true)
      expect(multiple_college_success.csa_props[:csa_badge].include?('2018, 2019 and 2020')).to eq(true)
      expect(college_success.csa_props[:csa_badge].include?('a href=/arkansas/college-success-award/>See more winners')).to eq(true)
      expect(multiple_college_success.csa_props[:csa_badge].include?('a href=/new-jersey/college-success-award/>See more winners')).to eq(true)
    end
  end

end