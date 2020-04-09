require "spec_helper"

include SchoolProfiles::CollegeReadinessConfig
describe SchoolProfiles::CollegeReadiness do
  let(:act_score_dt) { SchoolProfiles::CollegeReadinessConfig::ACT_SCORE }
  let(:act_participation_dt) { SchoolProfiles::CollegeReadinessConfig::ACT_PARTICIPATION }

  let(:sat_score_dt) { SchoolProfiles::CollegeReadinessConfig::SAT_SCORE }
  let(:sat_participation_dt) { SchoolProfiles::CollegeReadinessConfig::SAT_PARTICIPATION }

  let(:act_sat_912_participation_dt) { SchoolProfiles::CollegeReadinessConfig::ACT_SAT_PARTICIPATION_9_12 }
  let(:act_sat_participation_dt) { SchoolProfiles::CollegeReadinessConfig::ACT_SAT_PARTICIPATION }

  describe "#handle_ACT_SAT_to_display!" do

    let(:cv1) do
      FactoryBot.build(:school_metrics_value,
        school_value: 123,
        year: 2018)
    end

    let(:cv2) do
      FactoryBot.build(:school_metrics_value,
        school_value: 234,
        year: 2018)
    end

    let(:cv3) do
      FactoryBot.build(:school_metrics_value,
        school_value: 444,
        year: 2014)
    end

    subject(:handler) { ActSatHandler.new(hash) }

    context 'given hash contains only ACT content' do
      let(:hash) do
        {
          act_sat_participation_dt => [cv1],
          act_score_dt => [cv2],
          act_sat_912_participation_dt => []
        }
      end

      it 'sets school value to nil for all students for ACT_SAT combined participation data types' do
        expect { handler.handle_ACT_SAT_to_display! }.to change { handler.hash[act_sat_participation_dt].first.school_value }.from(123).to(nil)
      end

      it 'enforces latest year for ACT data type records' do
        hash[act_score_dt] << cv3

        expect { handler.handle_ACT_SAT_to_display! }.to change { handler.hash[act_score_dt].last.school_value }.from(444).to(nil)
      end

      it "ignores records for other subjects" do
        cv4 = FactoryBot.build(:school_metrics_value,
                subject: 'Mathematics',
                school_value: 123,
                year: 2018)

        hash[act_score_dt] << cv4

        expect { handler.handle_ACT_SAT_to_display! }.not_to change { handler.hash[act_score_dt].last.school_value }
      end

      it "ignores records for other CRDC breakdowns" do
        cv4 = FactoryBot.build(:school_metrics_value,
          breakdown: 'Hispanic',
          school_value: 123,
          year: 2018)

        hash[act_score_dt] << cv4

        expect { handler.handle_ACT_SAT_to_display! }.not_to change { handler.hash[act_score_dt].last.school_value }
      end
    end

    context 'given hash contains only SAT content' do
      let(:hash) do
        {
          act_sat_participation_dt => [cv1],
          sat_participation_dt => [cv2],
          act_sat_912_participation_dt => []
        }
      end

      it 'sets school value to nil for all students for ACT_SAT combined participation data types' do
        expect { handler.handle_ACT_SAT_to_display! }.to change { handler.hash[act_sat_participation_dt].first.school_value }.from(123).to(nil)
      end

      it 'enforces latest year for ACT data type records' do
        hash[sat_participation_dt] << cv3

        expect { handler.handle_ACT_SAT_to_display! }.to change { handler.hash[sat_participation_dt].last.school_value }.from(444).to(nil)
      end

      it "ignores records for other subjects" do
        cv4 = FactoryBot.build(:school_metrics_value,
                subject: 'Mathematics',
                school_value: 123,
                year: 2018)

        hash[sat_participation_dt] << cv4

        expect { handler.handle_ACT_SAT_to_display! }.not_to change { handler.hash[sat_participation_dt].last.school_value }
      end

      it "ignores records for other CRDC breakdowns" do
        cv4 = FactoryBot.build(:school_metrics_value,
          breakdown: 'Hispanic',
          school_value: 123,
          year: 2018)

        hash[sat_participation_dt] << cv4

        expect { handler.handle_ACT_SAT_to_display! }.not_to change { handler.hash[sat_participation_dt].last.school_value }
      end
    end

    context 'with both SAT and ACT content' do
      let(:hash) do
        {
          act_sat_participation_dt => [cv1],
          act_participation_dt => [cv2],
          sat_score_dt => [cv4],
          act_sat_912_participation_dt => []
        }
      end

      context 'when ACT & SAT data is <= 2 years apart' do
        let(:cv4) do
          FactoryBot.build(:school_metrics_value,
            school_value: 555,
            year: 2016)
          end

          it 'does not modify ACT or SAT content' do
            expect { handler.handle_ACT_SAT_to_display! }.not_to change { handler.hash[act_participation_dt].last.school_value }
            expect { handler.handle_ACT_SAT_to_display! }.not_to change { handler.hash[sat_score_dt].last.school_value }
          end
        end

        context 'when ACT & SAT data is > 2 years apart' do
          let(:cv4) do
            FactoryBot.build(:school_metrics_value,
              school_value: 555,
              year: 2014)
            end

            it 'rejects SAT data if ACT data is fresher' do
              expect { handler.handle_ACT_SAT_to_display! }.to change { handler.hash[sat_score_dt].first.school_value }.from(555).to(nil)
            end

        it 'rejects ACT data if SAT data is fresher' do
          hash[act_participation_dt] = [cv4]
          hash[sat_score_dt] = [cv2]

          expect { handler.handle_ACT_SAT_to_display! }.to change { handler.hash[act_participation_dt].first.school_value }.from(555).to(nil)
        end
      end
    end

    context 'with no SAT and no ACT content' do
      let(:hash) do
        {
          act_sat_participation_dt => [cv1],
          act_participation_dt => [],
          sat_score_dt => [],
          act_sat_912_participation_dt => [cv3]
        }
      end

      it 'retains only most recent ACT/SAT participation data' do
        expect { handler.handle_ACT_SAT_to_display! }.to change { handler.hash[act_sat_912_participation_dt].last.school_value }.from(444).to(nil)
      end

    end
  end

  context "for community data" do
    let(:cv1) do
      FactoryBot.build(:state_metrics_value,
        state_value: 123,
        year: 2018)
    end

    let(:cv2) do
      FactoryBot.build(:state_metrics_value,
        state_value: 234,
        year: 2018)
    end

    let(:hash) do
      {
        act_sat_participation_dt => [cv1],
        act_score_dt => [cv2],
        act_sat_912_participation_dt => []
      }
    end

    subject(:handler) { ActSatHandler.new(hash, "state_value") }

    it 'sets state value to nil for all students for ACT_SAT combined participation data types' do
      expect { handler.handle_ACT_SAT_to_display! }.to change { handler.hash[act_sat_participation_dt].first.state_value }.from(123).to(nil)
    end
  end
end