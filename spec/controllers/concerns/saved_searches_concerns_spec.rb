require 'spec_helper'

describe SavedSearchesConcerns do
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
      include SavedSearchesConcerns
    end
  end
  before(:each) { allow(controller).to receive(:current_user).and_return(user)}
  after(:each) { clean_models :gs_schooldb, SavedSearch, User }
  after(:all) { Object.send :remove_const, :FakeController }

  describe '#handle_html' do
    before do
      allow(controller).to receive(:redirect_back_or_default)
      allow(controller).to receive(:redirect_path)
    end
    it 'should call redirect_back_or_default' do
      allow(controller).to receive(:create_saved_search)
      allow(controller).to receive(:cookies).and_return({})
      allow(controller).to receive(:flash).and_return('')
      allow(controller).to receive(:flash_notice)
      expect(controller).to receive(:redirect_back_or_default)
      controller.handle_html(saved_search_params)
    end
    it 'should render a flash error when it failed to save a search' do
      allow(controller).to receive(:create_saved_search).and_return(Exception.new)
      allow(controller).to receive(:flash_error)
      expect(controller).to receive(:flash_error)
      controller.handle_html(saved_search_params)
    end
    context 'when the search successfully saved and is not a provisional user' do
      before do
        allow(controller).to receive(:flash).and_return('')
        allow(controller).to receive(:create_saved_search)
        allow(controller).to receive(:cookies).and_return({})
      end
      it 'should render a flash notice' do
        allow(controller).to receive(:flash_notice)
        expect(controller).to receive(:flash_notice)
        controller.handle_html(saved_search_params)
      end
      it 'should set a saved_search = success cookie' do
        allow(controller).to receive(:flash_notice)
        expect(controller).to receive(:cookies)
        controller.handle_html(saved_search_params)
      end
    end
  end

  describe '#handle_json' do
    it 'should render a json response when save is successful' do
      allow(controller).to receive(:create_saved_search)
      allow(controller).to receive(:render)
      expect(controller).to receive(:render).with( { json: {} } )
      controller.handle_json(saved_search_params)
    end
    it 'should render a json response with an error when the save failed' do
      allow(controller).to receive(:create_saved_search).and_return(Exception.new)
      allow(controller).to receive(:render)
      expect(controller).to receive(:render).with( { json: hash_including(error: anything) } )
      controller.handle_json(saved_search_params)
    end

  end

  describe '#create_saved_search' do
    it 'should save a search into the database' do
      expect(SavedSearch.count).to eq 0
      controller.send(:create_saved_search, saved_search_params.deep_dup)
      expect(SavedSearch.count).to eq 1
    end

    it 'should not return an array of errors if the search was saved into the database' do
      expect(SavedSearch.count).to eq 0
      errors = controller.send(:create_saved_search, saved_search_params.deep_dup)
      expect(SavedSearch.count).to eq 1
      expect(errors.count).to equal 0
    end

    it 'should save a search with the name ??' do
      # Cuz, you know, why not? PT-919
      question_mark_search_params = saved_search_params.deep_dup
      question_mark_search_params[:name] = '??'
      expect(SavedSearch.count).to eq 0
      controller.send(:create_saved_search, question_mark_search_params)
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

    [:name, :search_string, :num_results].each do |field|
      it "should return an array with error message(s) if #{field.to_s} is blank" do
        errors = controller.send(:create_saved_search, saved_search_params.deep_dup.merge({field => ''}) )
        expect(errors).to be_an_instance_of Array
        expect(errors.count).to_not equal 0
      end
    end
  end

end