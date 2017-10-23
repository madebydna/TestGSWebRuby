require 'spec_helper'

describe Admin::ApiAccountsController do

  describe '#display_selected_api_accounts' do
    test_size = 23
    before do
      test_size.times {|num| FactoryGirl.create(:api_account, account_added: Time.now + num)}
    end
    let (:params) {
      {all: nil, start: nil}
    }
    after do
      clean_models ApiAccount
    end

    let (:subject) {controller.send(:selected_api_accounts)}

    context 'when start is not specified' do
      it 'loads with 0 offset' do
        params = {}
        allow(controller).to receive(:params).and_return(params)
        expect(subject.size).to eq(test_size)
      end
    end


    context 'when start is specified' do

      it 'calculates offset by reference to OFFSET constant' do
        smaller_offset = 5
        stub_const("Admin::ApiAccountsController::OFFSET", smaller_offset)
        params[:start] = 6
        allow(controller).to receive(:params).and_return(params)
        expect(subject).to eq(ApiAccount.offset(smaller_offset).limit(smaller_offset))
      end

      it 'defaults to 0 if start is negative' do
        params[:start] = -5
        allow(controller).to receive(:params).and_return(params)
        expect(subject.first).to eq(ApiAccount.first)
      end

      it 'defaults to 0 if start is larger than total # of accounts' do
        params[:start] = test_size + 1
        allow(controller).to receive(:params).and_return(params)
        expect(subject.first).to eq(ApiAccount.first)
      end

    end

    context 'when all is specified' do
      it 'loads all api accounts' do
        params[:all] = true
        allow(controller).to receive(:params).and_return(params)
        expect(subject.size).to eq(test_size)
      end
    end
    
  end
end

