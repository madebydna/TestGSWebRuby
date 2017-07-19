require 'spec_helper'

describe SchoolCache do

  let!(:school) { FactoryGirl.create(:school) }
  let!(:test_data_breakdown) { FactoryGirl.create(:test_data_breakdown) }
  let!(:test_data_subject) { FactoryGirl.create(:test_data_subject) }

  after(:each) do
    clean_models :ca, School, TestDataSet, TestDataSchoolValue
    clean_models TestDataType, SchoolCache, TestDataBreakdown, TestDataSubject
  end

  [:characteristics, :esp_responses, :ratings, :test_scores].each do |key|
    describe "#cached_#{key}_data" do
      context 'with no cache row for this key' do
        it 'should return {}' do
          allow(SchoolCache).to receive(:for_school).and_return(nil)
          expect(SchoolCache.send("cached_#{key}_data".to_sym, school)).to eq ({})
        end
      end
    end
  end
end
