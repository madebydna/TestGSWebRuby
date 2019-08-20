require "spec_helper"

include SchoolProfiles::CollegeReadinessConfig
describe SchoolProfiles::CollegeReadiness do

  let(:college_readiness) { SchoolProfiles::CollegeReadiness.new(school_cache_data_reader: double) }

  describe "#enforce_latest_year_school_value_for_data_types!" do
    context 'hash does not have given data_types' do
      it 'returns nil' do
        hash       = {}
        data_types = ["Average SAT score", "SAT percent participation", "SAT percent college ready"]
        expect(college_readiness.enforce_latest_year_school_value_for_data_types!(hash, data_types)).to be_nil
      end
    end

    context 'hash includes given data type' do
      it 'returns the latest year' do
        data_types = "Average ACT score"

        cv1                      = SchoolProfiles::CollegeReadinessComponent::CharacteristicsValue.new
        cv1.subject              = 'All subjects'
        cv1.breakdown            = 'All students'
        cv1.year                 = "2018"
        cv1["school_value_2018"] = "yes"
        cv1["school_value_2014"] = "yes"
        cv1.school_value         = 123

        cv2              = SchoolProfiles::CollegeReadinessComponent::CharacteristicsValue.new
        cv2.subject      = 'All subjects'
        cv2.breakdown    = 'General-Education students'
        cv2.year         = "2014"
        cv2.school_value = 123

        hash = { "Average ACT score" => [cv1, cv2] }

        expect(college_readiness.enforce_latest_year_school_value_for_data_types!(hash, data_types)).to eq(cv1.year)
      end

      it 'sets all school values that do not hold max year data to nil' do

        data_types = "Average ACT score"

        cv1                      = SchoolProfiles::CollegeReadinessComponent::CharacteristicsValue.new
        cv1.subject              = 'All subjects'
        cv1.breakdown            = 'All students'
        cv1.year                 = "2018"
        cv1["school_value_2018"] = "yes"
        cv1["school_value_2014"] = "yes"
        cv1.school_value         = 123

        cv2              = SchoolProfiles::CollegeReadinessComponent::CharacteristicsValue.new
        cv2.subject      = 'All subjects'
        cv2.breakdown    = 'General-Education students'
        cv2.year         = "2014"
        cv2.school_value = 123

        cv3                      = SchoolProfiles::CollegeReadinessComponent::CharacteristicsValue.new
        cv3.subject              = 'All subjects'
        cv3.breakdown            = 'All students'
        cv3.year                 = "2012"
        cv3.school_value         = 123

        hash = { "Average ACT score" => [cv1, cv2, cv3] }
        college_readiness.enforce_latest_year_school_value_for_data_types!(hash, data_types)
        expect(cv1.school_value).to_not be_nil
        expect(cv3.school_value).to be_nil
      end
    end
  end

  describe "#remove_crdc_for_unfresh_data" do
    context 'with ACT & SAT content within 2 years of one another' do
      it 'does not mutate the hash' do

        cv1                      = SchoolProfiles::CollegeReadinessComponent::CharacteristicsValue.new
        cv1.subject              = 'All subjects'
        cv1.breakdown            = 'All students'
        cv1.year                 = 2018
        cv1["school_value_2018"] = "yes"
        cv1["school_value_2014"] = "yes"
        cv1.school_value         = 123

        cv4                      = SchoolProfiles::CollegeReadinessComponent::CharacteristicsValue.new
        cv4.subject              = 'All subjects'
        cv4.breakdown            = 'All students'
        cv4.year                 = 2016
        cv4["school_value_2018"] = "yes"
        cv4["school_value_2014"] = "yes"
        cv4.school_value         = 123

        hash = { "Average ACT score" => [cv1], "Average SAT score" => [cv4] }
        college_readiness.remove_crdc_for_unfresh_data(cv1.year, cv4.year, hash)
        expect(cv1.school_value).to_not be_nil
        expect(cv4.school_value).to_not be_nil
      end
    end

    context 'with ACT & SAT content not within 2 years of one another' do
      it 'does mutate the hash' do

        cv1                      = SchoolProfiles::CollegeReadinessComponent::CharacteristicsValue.new
        cv1.subject              = 'All subjects'
        cv1.breakdown            = 'All students'
        cv1.year                 = 2018
        cv1["school_value_2018"] = "yes"
        cv1["school_value_2014"] = "yes"
        cv1.school_value         = 123

        cv4                      = SchoolProfiles::CollegeReadinessComponent::CharacteristicsValue.new
        cv4.subject              = 'All subjects'
        cv4.breakdown            = 'All students'
        cv4.year                 = 2014
        cv4["school_value_2018"] = "yes"
        cv4["school_value_2014"] = "yes"
        cv4.school_value         = 123

        hash = { "Average ACT score" => [cv1], "Average SAT score" => [cv4] }
        college_readiness.remove_crdc_for_unfresh_data(cv1.year, cv4.year, hash)
        expect(cv1.school_value).to_not be_nil
        expect(cv4.school_value).to be_nil
      end
    end

  end 

  describe "#handle_ACT_SAT_to_display!" do

    context 'with an empty hash' do
      it 'the hash will nullify records we do not want to display' do
        hash = {}
        college_readiness.handle_ACT_SAT_to_display!(hash)
        expect(hash).to eq({})
      end
    end

    # it 'the hash will nullify records we do not want to display' do
      # act_data = "Average ACT score"

      #   cv1                      = SchoolProfiles::CollegeReadinessComponent::CharacteristicsValue.new
      #   cv1.subject              = 'All subjects'
      #   cv1.breakdown            = 'All students'
      #   cv1.year                 = "2018"
      #   cv1["school_value_2018"] = "yes"
      #   cv1["school_value_2014"] = "yes"
      #   cv1.school_value         = 123

      #   cv2              = SchoolProfiles::CollegeReadinessComponent::CharacteristicsValue.new
      #   cv2.subject      = 'All subjects'
      #   cv2.breakdown    = 'General-Education students'
      #   cv2.year         = "2014"
      #   cv2.school_value = 123

      #   cv3                      = SchoolProfiles::CollegeReadinessComponent::CharacteristicsValue.new
      #   cv3.subject              = 'All subjects'
      #   cv3.breakdown            = 'All students'
      #   cv3.year                 = "2012"
      #   cv3.school_value         = 123

      # sat_data = "Average SAT score"

      #   cv4                      = SchoolProfiles::CollegeReadinessComponent::CharacteristicsValue.new
      #   cv4.subject              = 'All subjects'
      #   cv4.breakdown            = 'All students'
      #   cv4.year                 = "2018"
      #   cv4["school_value_2018"] = "yes"
      #   cv4["school_value_2014"] = "yes"
      #   cv4.school_value         = 123

      #   cv5              = SchoolProfiles::CollegeReadinessComponent::CharacteristicsValue.new
      #   cv5.subject      = 'All subjects'
      #   cv5.breakdown    = 'General-Education students'
      #   cv5.year         = "2014"
      #   cv5.school_value = 123

      #   cv6                      = SchoolProfiles::CollegeReadinessComponent::CharacteristicsValue.new
      #   cv6.subject              = 'All subjects'
      #   cv6.breakdown            = 'All students'
      #   cv6.year                 = "2012"
      #   cv6.school_value         = 123


      #   hash = { "Average ACT score" => [cv1, cv2, cv3], "Average SAT score" => [cv4, cv5, cv6] }
      #   college_readiness.handle_ACT_SAT_to_display!(hash)
      #   expect(hash).to eq({})
    # end

    

    # it 'modifies the given hash - sets school values to nil' do
    #
    # end

    # it 'modifies the given hash - sets school values to nil' do
    #
    # end
  end
end