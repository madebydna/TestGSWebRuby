require 'spec_helper'

describe SavedSearchController do
  [DeferredActionConcerns, SavedSearchConcerns].each do | mod |
    it "should include #{mod.to_s}" do
      expect(SavedSearchController.ancestors.include?(mod)).to be_truthy
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

      optional_params.each do |param|
        it "should return an options hash with the #{param} key if #{param} is present in params" do
          expect(controller.send(:saved_search_params)[:options]).to have_key(param)
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

  describe '#attempt_saved_search' do
    context 'if the user is logged in' do
      before do
        allow(controller).to receive(:logged_in?).and_return(true)
        allow(controller).to receive(:create_saved_search)
        allow(controller).to receive(:saved_search_params)
        allow(controller).to receive(:redirect_back_or_default)
        allow(controller).to receive(:redirect_path)
      end

      it 'should call the create_saved_search method' do
        expect(controller).to receive(:create_saved_search)
        controller.send(:attempt_saved_search)
      end

      it 'should call the redirect_back_or_default_method' do
        expect(controller).to receive(:redirect_back_or_default)
        controller.send(:attempt_saved_search)
      end
    end

    context 'if the user is not logged in' do
      let(:saved_search_params) { { search_name: 'MySearch for Johnny' } }
      let(:join_url) { '/join' }
      before do
        allow(controller).to receive(:logged_in?).and_return(false)
        allow(controller).to receive(:saved_deferred_action)
        allow(controller).to receive(:saved_search_params).and_return(saved_search_params)
        allow(controller).to receive(:flash_notice)
        allow(controller).to receive(:redirect_to)
        allow(controller).to receive(:join_url).and_return(join_url)

      end
      it 'should call the saved_deferred action method with :saved_search_deferred' do
        expect(controller).to receive(:save_deferred_action).with(:saved_search_deferred, saved_search_params)
        controller.send(:attempt_saved_search)
      end

      it 'should call the flash notice method' do
        expect(controller).to receive(:flash_notice)
        controller.send(:attempt_saved_search)
      end
      it 'should call the redirect_to method with join_url' do
        expect(controller).to receive(:redirect_to).with(join_url)
        controller.send(:attempt_saved_search)
      end
    end
  end
end