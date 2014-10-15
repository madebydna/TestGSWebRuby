require 'spec_helper'

describe SavedSearchesController do
  [DeferredActionConcerns, SavedSearchesConcerns].each do | mod |
    it "should include #{mod.to_s}" do
      expect(SavedSearchesController.ancestors.include?(mod)).to be_truthy
    end
  end

  describe '#saved_search_params' do
    let(:params) do
      {
          search_name: 'Schools For Johnny',
          search_string: 'Dover, DE',
          num_results: 25,
          state: 'de',
          url: 'www.greatschools.org/delaware/dover/schools?st=private'
      }
    end

    required_fields_for_db = [:name, :search_string, :num_results]
    required_params = [:search_name, :search_string, :num_results]
    optional_params = [:state, :url]

    context "when all the required params (#{required_params.join(', ')}) are in params" do
      before { allow(controller).to receive(:params).and_return(params) }

      it 'should return a hash' do
        expect(controller.send(:saved_search_params)).to be_an_instance_of(Hash)
      end

      required_fields_for_db.each do |field|
       it "should return a hash with the #{field} key if the all required parameters are in params" do
         expect(controller.send(:saved_search_params)).to have_key(field)
       end
      end
    end

    context "when all the required params (#{required_params.join(', ')})  are NOT in params" do
      required_params.each do |param|
        it "should return false if the required param: #{param} is not present" do
          allow(controller).to receive(:params).and_return(params.except(param))
          expect(controller.send(:saved_search_params)).to be_falsey
        end
      end
    end

    context "when optional params (#{optional_params.join(', ')}) are present in params" do
      before { allow(controller).to receive(:params).and_return(params) }

      it 'should return a hash with the options key in the hash' do
        expect(controller.send(:saved_search_params)).to have_key(:options)
      end

      it 'should return a hash with the options key in the hash as serialized JSON' do
        options = controller.send(:saved_search_params)[:options]
        expect(JSON.parse(options)).to be_an_instance_of(Hash)
      end

      optional_params.each do |param|
        it "should return an options hash with the #{param} key if #{param} is present in params" do
          options = controller.send(:saved_search_params)[:options]
          expect(JSON.parse(options)).to have_key(param.to_s)
        end
      end
    end

    context "when optional params (#{optional_params.join(', ')}) are NOT present in params" do
      before { allow(controller).to receive(:params).and_return(params.except(*optional_params)) }

      it 'should return a hash WITHOUT the options key in the hash' do
        expect(controller.send(:saved_search_params)).to_not have_key(:options)
      end
    end
  end

  describe '#create' do
    context 'if the user is logged in' do
      let(:success) { {success: 'Save successful!'} }
      let(:error) { {error: 'Error!'} }
      before do
        allow(controller).to receive(:logged_in?).and_return(true)
        allow(controller).to receive(:saved_search_params)
      end

      it 'should call the handle_json method when the request is ajax' do
        allow_any_instance_of(ActionController::TestRequest).to receive(:xhr?).and_return(true)
        allow(controller).to receive(:handle_json)
        expect(controller).to receive(:handle_json)
        controller.create
      end
      it 'should call the handle_html method when the request is html' do
        allow_any_instance_of(ActionController::TestRequest).to receive(:xhr?).and_return(false)
        allow(controller).to receive(:handle_html)
        expect(controller).to receive(:handle_html)
        controller.create
      end
    end

    context 'if the user is not logged in' do
      let(:saved_search_params) { { search_name: 'MySearch for Johnny' } }
      let(:signin_url) { '/gsr/login' }
      before do
        allow(controller).to receive(:logged_in?).and_return(false)
        allow(controller).to receive(:saved_deferred_action)
        allow(controller).to receive(:saved_search_params).and_return(saved_search_params)
        allow(controller).to receive(:flash_notice)
        allow(controller).to receive(:redirect_to)
        allow(controller).to receive(:signin_url).and_return(signin_url)
      end
      it 'should call the saved_deferred action method with :saved_search_deferred' do
        expect(controller).to receive(:save_deferred_action).with(:saved_search_deferred, saved_search_params)
        controller.create
      end
    end
  end

  describe '#redirect_to_login' do
    let(:signin_url) { '/gsr/login' }
    before do
      allow(controller).to receive(:flash_notice)
      allow(controller).to receive(:redirect_to)
      allow(controller).to receive(:signin_url).and_return(signin_url)
    end

    it 'should call the flash notice method' do
      expect(controller).to receive(:flash_notice)
      controller.send(:redirect_to_login)
    end

    it 'should call the redirect_to method with signin_url when its not an ajax request' do
      allow_any_instance_of(ActionController::TestRequest).to receive(:xhr?).and_return(false)
      expect(controller).to receive(:redirect_to).with(signin_url)
      controller.send(:redirect_to_login)
    end

    it 'should call the render method with json arguments when its an ajax request' do
      allow_any_instance_of(ActionController::TestRequest).to receive(:xhr?).and_return(true)
      expect(controller).to receive(:render).with( {json: hash_including(redirect: signin_url)})
      controller.send(:redirect_to_login)
    end
  end

  describe '#destroy' do
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
    before(:each) do
      allow(controller).to receive(:current_user).and_return(user)
      allow(controller).to receive(:render)
    end
    after(:each) { clean_models :gs_schooldb, SavedSearch, User }

    it 'should destroy their saved search if they have a saved search with that id' do
      allow(controller).to receive(:logged_in?).and_return(true)
      allow(controller).to receive(:params).and_return({id: 1})
      controller.send(:create_saved_search, saved_search_params.deep_dup)

      expect(SavedSearch.count).to eq 1
      controller.send(:destroy)
      expect(SavedSearch.count).to eq 0
    end
    it 'should not destroy the saved search if it does not belong to the user' do
      controller.send(:create_saved_search, saved_search_params.deep_dup)
      user2 = FactoryGirl.create(:user)
      allow(controller).to receive(:current_user).and_return(user2)
      controller.send(:create_saved_search, saved_search_params.deep_dup)

      expect(SavedSearch.count).to eq 2

      allow(controller).to receive(:logged_in?).and_return(true)
      allow(controller).to receive(:params).and_return({id: 1})
      controller.send(:destroy)
      expect(SavedSearch.count).to eq 2
    end
    it 'should redirect the user to the login page if they are not logged in' do
      allow(controller).to receive(:logged_in?).and_return(false)
      allow(controller).to receive(:redirect_to_login)
      expect(controller).to receive(:redirect_to_login)

      controller.send(:destroy)
    end
    it 'should render an empty json hash if there is no record to delete' do
      allow(controller).to receive(:logged_in?).and_return(true)
      allow(controller).to receive(:params).and_return({id: 2})
      controller.send(:create_saved_search, saved_search_params.deep_dup)

      expect(controller).to receive(:render).with( { json: hash_not_including( { error: anything } ) } )
      controller.send(:destroy)
    end
  end
end