require 'spec_helper'

describe TestScoresCaching::TestScoresCacherGsdata do

  let(:school) { build(:school, state: whitelist_state, level_code: 'h') }
  let(:cacher) { TestScoresCaching::TestScoresCacherGsdata.new(school) }
  let(:whitelist_state) { TestScoresCaching::TestScoresCacherGsdata::ALT_NULL_STATE_FILTER.first }

  describe "#school_results_filter" do
    context 'data_type_id is not present' do
      let(:state) { 'test' }
      it 'returns the given query result' do
        qr     = [OpenStruct.new({ state: state, data_type_id: 1 })]
        result = cacher.school_results_filter(qr)
        expect(result).to eq(qr)
      end
    end

    context 'data_type_id is present' do
      context 'state is in whitelist' do
        context 'school has no test scores in current year based on states latest year.' do
          before(:each) do
            allow(cacher).to receive(:query_result_max_year).and_return 2018
            allow(cacher).to receive(:state_latest_year).and_return 2019
          end

          context 'school contains HS level"' do
            let(:school) { build(:school, state: whitelist_state, level_code: 'h') }
            it 'returns an empty array' do
              qr     = [OpenStruct.new({ state: whitelist_state, data_type_id: 1 })]
              result = cacher.school_results_filter(qr)
              expect(result).to eq([])
            end
          end

          context 'school does not contain HS level"' do
            let(:school) { build(:school, state: whitelist_state, level_code: 'm') }

            it 'returns the given query result' do
              allow(cacher).to receive(:query_result_max_year).and_return 2018
              allow(cacher).to receive(:state_latest_year).and_return 2019
              qr     = [OpenStruct.new({ state: whitelist_state, data_type_id: 1 })]
              result = cacher.school_results_filter(qr)
              expect(result).to eq(qr)
            end
          end
        end

        context 'school has test scores in current year based on states latest year' do
          it 'returns the given query result' do
            allow(cacher).to receive(:query_result_max_year).and_return 2019
            allow(cacher).to receive(:state_latest_year).and_return 2019
            qr     = [OpenStruct.new({ state: whitelist_state, data_type_id: 1 })]
            result = cacher.school_results_filter(qr)
            expect(result).to eq(qr)
          end
        end
      end

      context 'state is not in whitelist' do
        let(:state) { 'test' }
        it 'returns the given query result' do
          qr     = [OpenStruct.new({ state: state, data_type_id: 1 })]
          result = cacher.school_results_filter(qr)
          expect(result).to eq(qr)
        end
      end
    end
  end
end