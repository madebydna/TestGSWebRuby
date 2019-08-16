require "spec_helper"

include SchoolProfiles::CollegeReadinessConfig
describe SchoolProfiles::CollegeReadiness do

  describe "#enforce_latest_year_school_value_for_data_types!" do
    let(:college_readiness) { SchoolProfiles::CollegeReadiness.new(school_cache_data_reader: double) }

    context 'hash does not have given data_types' do
      it 'returns nil' do
        hash = {}
        data_types = ["Average SAT score", "SAT percent participation", "SAT percent college ready"]
        expect(college_readiness.enforce_latest_year_school_value_for_data_types!(hash, data_types)).to be_nil
      end
    end
    
    context 'hash includes given data type' do
      it 'should ' do

        data_types = ["Average ACT score"]

        cc = SchoolProfiles::CollegeReadinessComponent::CharacteristicsValue.new
        hash = {"Average ACT score" => [cc]}
        allow(cc).to receive(:all_subjects_and_students?).and_return true

        expect(college_readiness.enforce_latest_year_school_value_for_data_types!(hash, data_types)).to eq('2018')


        data_types
      end
    end
  end
end