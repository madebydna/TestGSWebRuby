require "spec_helper"

include MetricsCaching::CollegeReadinessConfig
describe SchoolProfiles::CollegeReadiness do
  let(:act_score_dt) { ACT_SCORE }
  let(:act_participation_dt) { ACT_PARTICIPATION }

  let(:sat_score_dt) { SAT_SCORE }
  let(:sat_participation_dt) { SAT_PARTICIPATION }

  let(:act_sat_912_participation_dt) { ACT_SAT_PARTICIPATION_9_12 }
  let(:act_sat_participation_dt) { ACT_SAT_PARTICIPATION }

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

      it 'removes ACT_SAT combined participation data types' do
        handler.handle_ACT_SAT_to_display!
        expect(handler.hash).to_not include(act_sat_participation_dt)
      end

      it 'enforces latest year for ACT data type records' do
        hash[act_score_dt] << cv3
        expect(handler.hash[act_score_dt]).to include(cv3)
        handler.handle_ACT_SAT_to_display!
        expect(hash[act_score_dt]).to_not include(cv3)
      end

      it "ignores records for other subjects" do
        cv4 = FactoryBot.build(:school_metrics_value,
                subject: 'Mathematics',
                school_value: 123,
                year: 2015)

        hash[act_score_dt] << cv4
        handler.handle_ACT_SAT_to_display!
        expect(hash[act_score_dt]).to include(cv4)
      end

      it "ignores records for other CRDC breakdowns" do
        cv4 = FactoryBot.build(:school_metrics_value,
          breakdown: 'Hispanic',
          school_value: 123,
          year: 2018)

        hash[act_score_dt] << cv4
        handler.handle_ACT_SAT_to_display!
        expect(hash[act_score_dt]).to include(cv4)
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

      it 'removes ACT_SAT combined participation data types' do
        handler.handle_ACT_SAT_to_display!
        expect(handler.hash).to_not include(act_sat_participation_dt)
      end

      it 'enforces latest year for ACT data type records' do
        hash[sat_participation_dt] << cv3
        expect(handler.hash[sat_participation_dt]).to include(cv3)
        handler.handle_ACT_SAT_to_display!
        expect(handler.hash[sat_participation_dt]).to_not include(cv3)
      end

      it "ignores records for other subjects" do
        cv4 = FactoryBot.build(:school_metrics_value,
                subject: 'Mathematics',
                school_value: 123,
                year: 2015)

        hash[sat_participation_dt] << cv4
        handler.handle_ACT_SAT_to_display!
        expect(handler.hash[sat_participation_dt]).to include(cv4)
      end

      it "ignores records for other CRDC breakdowns" do
        cv4 = FactoryBot.build(:school_metrics_value,
          breakdown: 'Hispanic',
          school_value: 123,
          year: 2016)

        hash[sat_participation_dt] << cv4
        handler.handle_ACT_SAT_to_display!
        expect(handler.hash[sat_participation_dt]).to include(cv4)
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
            handler.handle_ACT_SAT_to_display!
            expect(handler.hash).to include(act_participation_dt)
            expect(handler.hash).to include(sat_score_dt)
          end
        end

      context 'when ACT & SAT data is > 2 years apart' do
        let(:cv4) do
          FactoryBot.build(:school_metrics_value,
            school_value: 555,
            year: 2014)
        end

        it 'rejects SAT data if ACT data is fresher' do
          handler.handle_ACT_SAT_to_display!
          expect(handler.hash).to_not include(sat_score_dt)
        end

        it 'rejects ACT data if SAT data is fresher' do
          hash[act_participation_dt] = [cv4]
          hash[sat_score_dt] = [cv2]
          handler.handle_ACT_SAT_to_display!
          expect(handler.hash).to_not include(act_participation_dt)
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
        handler.handle_ACT_SAT_to_display!
        expect(handler.hash[act_sat_912_participation_dt]).to be_empty
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

    subject(:handler) { ActSatHandler.new(hash) }

    it 'removes ACT_SAT combined participation data types' do
      handler.handle_ACT_SAT_to_display!
      expect(handler.hash).to_not include(act_sat_participation_dt)
    end
  end
end