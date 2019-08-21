require "spec_helper"

include SchoolProfiles::CollegeReadinessConfig
describe SchoolProfiles::CollegeReadiness do
  #
  # describe "#enforce_latest_year_school_value_for_data_types!" do
  #   context 'hash does not have given data_types' do
  #     it 'returns nil' do
  #       hash       = {}
  #       data_types = ["Average SAT score", "SAT percent participation", "SAT percent college ready"]
  #       expect(college_readiness.enforce_latest_year_school_value_for_data_types!(hash, data_types)).to be_nil
  #     end
  #   end
  #
  #   context 'hash includes given data type' do
  #     it 'returns the latest year' do
  #       data_types = "Average ACT score"
  #
  #       cv1                      = SchoolProfiles::CollegeReadinessComponent::CharacteristicsValue.new
  #       cv1.subject              = 'All subjects'
  #       cv1.breakdown            = 'All students'
  #       cv1.year                 = "2018"
  #       cv1["school_value_2018"] = "yes"
  #       cv1["school_value_2014"] = "yes"
  #       cv1.school_value         = 123
  #
  #       cv2              = SchoolProfiles::CollegeReadinessComponent::CharacteristicsValue.new
  #       cv2.subject      = 'All subjects'
  #       cv2.breakdown    = 'General-Education students'
  #       cv2.year         = "2014"
  #       cv2.school_value = 123
  #
  #       hash = { "Average ACT score" => [cv1, cv2] }
  #
  #       expect(college_readiness.enforce_latest_year_school_value_for_data_types!(hash, data_types)).to eq(cv1.year)
  #     end
  #
  #     it 'sets all school values that do not hold max year data to nil' do
  #
  #       data_types = "Average ACT score"
  #
  #       cv1                      = SchoolProfiles::CollegeReadinessComponent::CharacteristicsValue.new
  #       cv1.subject              = 'All subjects'
  #       cv1.breakdown            = 'All students'
  #       cv1.year                 = "2018"
  #       cv1["school_value_2018"] = "yes"
  #       cv1["school_value_2014"] = "yes"
  #       cv1.school_value         = 123
  #
  #       cv2              = SchoolProfiles::CollegeReadinessComponent::CharacteristicsValue.new
  #       cv2.subject      = 'All subjects'
  #       cv2.breakdown    = 'General-Education students'
  #       cv2.year         = "2014"
  #       cv2.school_value = 123
  #
  #       cv3              = SchoolProfiles::CollegeReadinessComponent::CharacteristicsValue.new
  #       cv3.subject      = 'All subjects'
  #       cv3.breakdown    = 'All students'
  #       cv3.year         = "2012"
  #       cv3.school_value = 123
  #
  #       hash = { "Average ACT score" => [cv1, cv2, cv3] }
  #       college_readiness.enforce_latest_year_school_value_for_data_types!(hash, data_types)
  #       expect(cv1.school_value).to_not be_nil
  #       expect(cv3.school_value).to be_nil
  #     end
  #   end
  # end

  describe "#handle_ACT_SAT_to_display!" do

    context 'with an empty hash' do
      it 'the hash will nullify records we do not want to display' do
        hash = {}
        handler = ActSatHandler.new(hash)
        handler.handle_ACT_SAT_to_display!
        expect(handler.hash).to eq({})
      end
    end

    context 'with act content only' do
      it 'sets school value to nil for all students for ACT_SAT data types' do
        cv1                      = SchoolProfiles::CollegeReadinessComponent::CharacteristicsValue.new
        cv1.subject              = 'All subjects'
        cv1.breakdown            = 'All students'
        cv1.year                 = "2018"
        cv1["school_value_2018"] = "yes"
        cv1["school_value_2014"] = "yes"
        cv1.school_value         = 123

        act_sat_data_type = SchoolProfiles::CollegeReadinessConfig::ACT_SAT_PARTICIPATION
        act_data_type = SchoolProfiles::CollegeReadinessConfig::ACT_SCORE
        hash = {
          act_sat_data_type      => [cv1],
          act_data_type      => [cv1],
          SchoolProfiles::CollegeReadinessConfig::ACT_SAT_PARTICIPATION_9_12 => []
        }

        handler = ActSatHandler.new(hash)

        expect(handler.hash[act_sat_data_type].first.school_value).to_not be nil
        handler.handle_ACT_SAT_to_display!
        expect(handler.hash[act_sat_data_type].first.school_value).to be nil
      end

      it 'sets school value to nil for all students and subjects for ACT data types where no max year data' do

      end
    end

    context 'with sat content only'
    context 'with both sat and act content'
    context 'with no sat and no act content'

  end
end