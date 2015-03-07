require 'spec_helper'

#TODO when we refactor the ratings cacher into classes,  move this spec and rename it accordingly.

describe SchoolCache do

  let!(:school) { FactoryGirl.create(:school, id:1) }
  let!(:test_data_breakdown) { FactoryGirl.create(:test_data_breakdown) }
  let!(:test_data_subject) { FactoryGirl.create(:test_data_subject) }

  after(:each) do
    clean_models :ca, School, TestDataSet, TestDataSchoolValue
    clean_models TestDataType, SchoolCache, TestDataBreakdown, TestDataSubject
  end

  describe '#ratings' do

    context 'when a school has ratings data' do
      let!(:test_data_set) do
        FactoryGirl.create(
          :test_data_set,
          :with_school_values,
          data_type_id: 1,
          breakdown_id: 1,
          subject_id: 1,
          display_target: 'ratings',
          school_id: 1,
          value_float: 2,
          value_text: '3'
        )
      end

      it 'should insert ratings for the school' do
        Cacher.ratings_cache_for_school(school)

        cache_row = SchoolCache.where("school_id = ? and state = ?", 1,'ca')

        expect(cache_row).to_not be_empty
        expect(cache_row.size).to eq(1)
        ratings = JSON.parse(cache_row[0].value)
        expect(ratings.size).to eq(1)
        expect(ratings[0]['data_type_id']).to eq(1)
        expect(ratings[0]['school_value_float']).to eq(2)
        expect(ratings[0]['school_value_text']).to eq('3')
      end
    end

    context 'when a school does not have ratings data' do

      it 'should not insert ratings for the school' do
        Cacher.ratings_cache_for_school(school)

        cache_row = SchoolCache.where("school_id = ? and state = ?", 1,'ca')

        expect(cache_row).to be_empty
      end
    end

    context 'when a school does not have school values' do

      let!(:test_data_set) { FactoryGirl.create(:test_data_set, data_type_id: 1, display_target: 'ratings')}
      let!(:test_data_set) { FactoryGirl.create(:test_data_set, data_type_id: 2, display_target: 'ratings')}

      it 'should not insert ratings for the school' do
        Cacher.ratings_cache_for_school(school)

        cache_row = SchoolCache.where("school_id = ? and state = ?", 1,'ca')

        expect(cache_row).to be_empty
      end
    end
  end
end
