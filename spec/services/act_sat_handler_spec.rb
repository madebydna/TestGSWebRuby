require "spec_helper"

include SchoolProfiles::CollegeReadinessConfig
describe SchoolProfiles::CollegeReadiness do
  describe "#handle_ACT_SAT_to_display!" do

    let(:cv1) { SchoolProfiles::CollegeReadinessComponent::CharacteristicsValue.new }
    let(:cv2) { SchoolProfiles::CollegeReadinessComponent::CharacteristicsValue.new }
    let(:cv3) { SchoolProfiles::CollegeReadinessComponent::CharacteristicsValue.new }
    let(:act_score_dt) { SchoolProfiles::CollegeReadinessConfig::ACT_SCORE }
    let(:act_participation_dt) { SchoolProfiles::CollegeReadinessConfig::ACT_PARTICIPATION }
    let(:act_sat_912_participation_dt) { SchoolProfiles::CollegeReadinessConfig::ACT_SAT_PARTICIPATION_9_12 }
    let(:act_sat_participation_dt) { SchoolProfiles::CollegeReadinessConfig::ACT_SAT_PARTICIPATION }

    context 'given hash contains only ACT content' do

      it 'sets school value to nil for all students for ACT_SAT data types' do
        cv1.subject              = 'All subjects'
        cv1.breakdown            = 'All students'
        cv1.year                 = "2018"
        cv1["school_value_2018"] = 100
        cv1["school_value_2014"] = 200
        cv1.school_value         = 123

        cv2.subject              = 'All subjects'
        cv2.breakdown            = 'All students'
        cv2.year                 = "2018"
        cv2["school_value_2018"] = 100
        cv2["school_value_2014"] = 200
        cv2.school_value         = 234

        hash = {
          act_sat_participation_dt     => [cv1],
          act_score_dt         => [cv2],
          act_sat_912_participation_dt => []
        }

        handler = ActSatHandler.new(hash)

        expect(handler.hash[act_sat_participation_dt].first.school_value).to_not be nil
        handler.handle_ACT_SAT_to_display!
        expect(handler.hash[act_sat_participation_dt].first.school_value).to be nil
      end

      context 'data type is for all students and subjects' do

        it 'sets school value to nil for ACT data types where no max year data' do
          cv1.subject              = 'All subjects'
          cv1.breakdown            = 'All students'
          cv1.year                 = "2018"
          cv1["school_value_2018"] = 100
          cv1["school_value_2014"] = 300
          cv1.school_value         = 123

          cv2.subject      = 'All subjects'
          cv2.breakdown    = 'All students'
          cv2.year         = "2014"
          cv2.school_value = 123

          hash = {
            act_participation_dt => [cv1],
            act_score_dt   => [cv2]
          }

          handler = ActSatHandler.new(hash)

          expect(handler.hash[act_participation_dt].first.school_value).to_not be nil
          expect(handler.hash[act_score_dt].first.school_value).to_not be nil
          handler.handle_ACT_SAT_to_display!
          expect(handler.hash[act_participation_dt].first.school_value).to_not be nil
          expect(handler.hash[act_score_dt].first.school_value).to be nil
        end
      end

      context 'data type is not for all students and subjects' do
        it 'does not modify the school value for ACT data types' do
          cv1.subject              = 'Test Subject'
          cv1.breakdown            = 'Test students'
          cv1.year                 = "2018"
          cv1["school_value_2018"] = 345
          cv1["school_value_2014"] = 456
          cv1.school_value         = 123

          cv2.subject      = 'Test subject'
          cv2.breakdown    = 'Test students'
          cv2.year         = "2014"
          cv2.school_value = 123

          hash            = {
            act_participation_dt => [cv1],
            act_score_dt   => [cv2]
          }

          handler = ActSatHandler.new(hash)

          expect(handler.hash[act_participation_dt].first.school_value).to_not be nil
          expect(handler.hash[act_score_dt].first.school_value).to_not be nil
          handler.handle_ACT_SAT_to_display!
          expect(handler.hash[act_participation_dt].first.school_value).to_not be nil
          expect(handler.hash[act_score_dt].first.school_value).to_not be nil
        end
      end
    end

    context 'given hash contains only SAT content' do

    end

    context 'with no SAT and no ACT content' do

      # it 'should return data for act sat participation'
      # it 'should prioritize act/sat participation for 9-12 over 11-12'

      # TODO: Fix this test to accurately reflect what is being tested
      it 'sets school value to nil for data older than max year for act_sat data' do
        cv1.breakdown = 'All students'
        cv1.year = '2018'
        cv1.school_value = 123

        cv2.breakdown = 'All students'
        cv2.year = '2014'
        cv2.school_value = 234

        cv3.breakdown = 'Hispanic'
        cv3.year = '2018'
        cv3.school_value = 345

        hash = {
          act_sat_participation_dt     => [cv1],
          act_sat_912_participation_dt => [cv2, cv3]
        }

        handler = ActSatHandler.new(hash)

        handler.handle_ACT_SAT_to_display!
        expect(handler.hash[act_sat_participation_dt].first.school_value).to be nil
        expect(handler.hash[act_sat_912_participation_dt].first.school_value).to be nil
        expect(handler.hash[act_sat_912_participation_dt].last.school_value).to_not be nil

      end
    end

    context 'with both SAT and ACT content' do

    end 
  end

  def create_characteristics_value()

  end
end