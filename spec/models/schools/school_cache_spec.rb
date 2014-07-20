require 'spec_helper'

#TODO when we refactor the school cache script into classes then move this spec and rename it accordingly.
#This is a temporary way of adding tests. We should not be calling the script from the test directly.

describe SchoolCache do

  let!(:school) { FactoryGirl.create(:school, id:1) }

  after(:each) do
    clean_models :ca, School, TestDataSet, TestDataSchoolValue
    clean_models TestDataType, SchoolCache
  end

  describe '#ratings' do

    context 'when a school has ratings data' do
      let!(:test_data_set) do
        FactoryGirl.create(
          :test_data_set,
          :with_school_values,
          data_type_id: 1,
          display_target: 'ratings',
          school_id: 1,
          value_float: 2,
          value_text: '3'
        )
      end

      it 'should insert ratings for the school' do
        system("rails runner script/populate_school_cache_table.rb ratings ca 1")

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
        system("rails runner script/populate_school_cache_table.rb ratings ca 1")

        cache_row = SchoolCache.where("school_id = ? and state = ?", 1,'ca')

        expect(cache_row).to be_empty
      end
    end

    context 'when a school does not have school values' do

      let!(:test_data_set) { FactoryGirl.create(:test_data_set, data_type_id: 1, display_target: 'ratings')}
      let!(:test_data_set) { FactoryGirl.create(:test_data_set, data_type_id: 2, display_target: 'ratings')}

      it 'should not insert ratings for the school' do
        system("rails runner script/populate_school_cache_table.rb ratings ca 1")

        cache_row = SchoolCache.where("school_id = ? and state = ?", 1,'ca')

        expect(cache_row).to be_empty
      end
    end
  end

  describe '#test_scores' do

    context 'when a school has test scores' do

      before do
        @proficiency_band = TestProficiencyBand.create(id: 99, name: 'a proficiency band')
      end

      after do
        clean_models TestProficiencyBand
      end

      let!(:test_data_set) do
        FactoryGirl.create(
          :test_data_set,
          :with_school_values,
          data_type_id: 1,
          display_target: 'desktop',
          school_id: 1,
          value_float: 2,
          value_text: '3',
          number_tested: 300
        )
      end

      let!(:test_data_type) do
        FactoryGirl.create(:test_data_type, id: 1)
      end

      it 'should insert test scores for the school' do
        system("rails runner script/populate_school_cache_table.rb test_scores ca 1")

        cache_row = SchoolCache.where("school_id = ? and state = ?", 1,'ca')

        expect(cache_row).to_not be_empty
        expect(cache_row.size).to eq(1)
        test_scores = JSON.parse(cache_row[0].value)
        expect(test_scores.size).to eq(1)
        expect(test_scores.keys.first).to eq('1')
        expect(test_scores.seek(
          '1',
          'grades',
          '14',
          'level_code',
          'e,m,h',
          'All subjects',
          '2013',
          'score'
        )).to eq('3')
        expect(test_scores.seek(
          '1',
          'grades',
          '14',
          'level_code',
          'e,m,h',
          'All subjects',
          '2013',
          'number_students_tested'
        )).to eq(300)
      end

      it 'should insert proficiency_band with the cached data' do
        test_data_set.proficiency_band_id = @proficiency_band.id
        test_data_set.save
        system("rails runner script/populate_school_cache_table.rb test_scores ca 1")

        cache_row = SchoolCache.where("school_id = ? and state = ?", 1,'ca')

        test_scores = JSON.parse(cache_row[0].value)

        test_scores.seek(
          '1',
          'grades',
          '14',
          'level_code',
          'e,m,h',
          'All subjects',
          '2013'
        ).keys.each do |key|
          expect(key).to include 'a proficiency band'
        end
      end
    end
  end
end