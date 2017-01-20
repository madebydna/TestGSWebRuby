require 'spec_helper'


describe SchoolCacheQuery do

  describe '#query_and_use_cache_keys' do
    subject { school_cache_query.query_and_use_cache_keys }

    context 'when asking for 2 out of 3 cache keys' do
      before do
        FactoryGirl.create(:school_characteristic_responses, state: 'CA', school_id: 1)
        FactoryGirl.create(:cached_ratings, state: 'CA', school_id: 1)
        FactoryGirl.create(:school_cache_esp_responses, state: 'CA', school_id: 1)
      end
      after do
        clean_models :gs_schooldb, SchoolCache
      end
      let(:school_cache_query) do
        school_cache_query = SchoolCacheQuery.new
        school_cache_query.include_schools('CA', 1)
        school_cache_query.include_cache_keys(['ratings', 'esp_responses'])
        school_cache_query
      end

      it 'should return only cached_ratings' do
        expect(subject.size).to eq(2)
        expect(subject.map(&:name)).to include('ratings')
        expect(subject.map(&:name)).to include('esp_responses')
      end
    end
  end

  describe '#matching_schools_clause' do
    subject { query.matching_schools_clause }
    context 'with no state or schools' do
      let(:query) do
        SchoolCacheQuery.new
      end
      it { is_expected.to eq('(false = true)') }
    end
    context 'with one state and no schools' do
      let(:query) do
        SchoolCacheQuery.new.tap do |q|
          q.include_schools('CA', [])
        end
      end
      it { is_expected.to eq('(false = true)') }
    end
    context 'with two states and no schools' do
      let(:query) do
        SchoolCacheQuery.new.tap do |q|
          q.include_schools('CA', []).include_schools('DE', [])
        end
      end
      it { is_expected.to eq('(false = true)') }
    end
    context 'with one state and one school' do
      let(:query) do
        SchoolCacheQuery.new.tap do |q|
          q.include_schools('CA', [1])
        end
      end
      it { is_expected.to eq("((false = true) OR (`school_cache`.`state` = 'CA' AND `school_cache`.`school_id` IN (1)))") }
    end
    context 'with one state and two schools' do
      let(:query) do
        SchoolCacheQuery.new.tap do |q|
          q.include_schools('CA', [1,2])
        end
      end
      it { is_expected.to eq("((false = true) OR (`school_cache`.`state` = 'CA' AND `school_cache`.`school_id` IN (1, 2)))") }
    end
    context 'with two states and two schools each' do
      let(:query) do
        SchoolCacheQuery.new.tap do |q|
          q.include_schools('CA', [1,2]).include_schools('DE', [3,4])
        end
      end
      it { is_expected.to eq("(((false = true) OR (`school_cache`.`state` = 'CA' AND `school_cache`.`school_id` IN (1, 2))) OR (`school_cache`.`state` = 'DE' AND `school_cache`.`school_id` IN (3, 4)))") }
    end
  end

end
