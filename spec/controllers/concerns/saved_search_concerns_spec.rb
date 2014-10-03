require 'spec_helper'

describe SavedSearchConcerns do
  let(:controller) { FakeController.new }
  let(:user) {FactoryGirl.create(:user)}
  let(:saved_search_params) do
    {
        name: 'Schools For Johnny',
        search_string: 'Dover, DE',
        num_results: 25,
        options: {
            state: 'de',
            url: 'www.greatschools.org/delaware/dover/schools?st=private'
        }
    }
  end

  before(:all) do
    class FakeController
      include SavedSearchConcerns
    end
  end
  before(:each) { allow(controller).to receive(:current_user).and_return(user)}
  after(:each) { clean_models :gs_schooldb, SavedSearch, User }
  after(:all) { Object.send :remove_const, :FakeController }

  describe '#create_saved_search' do
    it 'should save a search into the database' do
      expect(SavedSearch.count).to eq 0
      controller.send(:create_saved_search, saved_search_params.deep_dup)
      expect(SavedSearch.count).to eq 1
    end
    context 'when there is an already existing search with the same search name in the database' do
      before do
        user.saved_searches.create!(saved_search_params)
      end
      it 'should not overwrite the existing search' do
        expect(SavedSearch.count).to eq 1
        controller.send(:create_saved_search, saved_search_params.deep_dup)
        expect(SavedSearch.count).to eq 2
      end
      it 'should use "search name + (1)" as the search name if there is only one occurrence' do
        expect(SavedSearch.count).to eq 1
        controller.send(:create_saved_search, saved_search_params.deep_dup)
        expect(SavedSearch.count).to eq 2
        expect(SavedSearch.last.name).to eq("#{saved_search_params.deep_dup[:name]}(1)")
      end
      it 'should use "search name + (3)" as the search name if there are 3 occurrences' do
        saved_search_params1 = saved_search_params.merge(name: 'Schools For Johnny(1)')
        saved_search_params2 = saved_search_params.merge(name: 'Schools For Johnny(2)')
        user.saved_searches.create!(saved_search_params1)
        user.saved_searches.create!(saved_search_params2)
        expect(SavedSearch.count).to eq 3
        controller.send(:create_saved_search, saved_search_params.deep_dup)
        expect(SavedSearch.count).to eq 4
        expect(SavedSearch.last.name).to eq("#{saved_search_params.deep_dup[:name]}(3)")
      end
    end
  end
end