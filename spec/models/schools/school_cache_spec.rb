require 'spec_helper'

describe SchoolCache do

  let!(:school) { FactoryBot.create(:school) }
  let!(:test_data_breakdown) { FactoryBot.create(:test_data_breakdown) }
  let!(:test_data_subject) { FactoryBot.create(:test_data_subject) }

  after(:each) do
    clean_models :ca, School, TestDataSet, TestDataSchoolValue
    clean_models TestDataType, SchoolCache, TestDataBreakdown, TestDataSubject
  end

  %i(metrics esp_responses ratings test_scores_gsdata).each do |key|
    describe "#cached_#{key}_data" do
      context 'with no cache row for this key' do
        it 'should return {}' do
          allow(SchoolCache).to receive(:for_school).and_return(nil)
          expect(SchoolCache.send("cached_#{key}_data".to_sym, school)).to eq ({})
        end
      end
    end
  end

  describe '.on_rw_db' do
    context 'With read/write connection' do
      before do
        expect(SchoolCache.connection_config[:connection_name]).to eq('gs_schooldb')
      end
      after do
        expect(SchoolCache.connection_config[:connection_name]).to eq('gs_schooldb')
      end
      it 'should have correct connection name' do
        SchoolCache.on_rw_db do
          expect(SchoolCache.connection_config[:connection_name]).to eq('gs_schooldb_rw')
        end
      end
    end
  end
end
