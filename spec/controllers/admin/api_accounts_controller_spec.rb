require 'spec_helper'

describe Admin::ApiAccountsController do

  describe '#display_selected_api_accounts' do
    test_size = 101
    before do
      test_size.times {|num| FactoryBot.create(:api_account, account_added: Time.now + num)}
      allow(controller).to receive(:params).and_return(params)
    end
    let (:params) {{}}
    after do
      clean_models ApiAccount
    end

    let (:subject) {controller.send(:selected_api_accounts)}

    context 'when start is not specified' do
      it 'loads with 0 offset' do
        expect(subject.first.id).to eq(ApiAccount.first.id)
      end
    end


    context 'when start is specified' do

      it 'calculates offset by reference to OFFSET constant' do
        smaller_offset = 5
        stub_const("Admin::ApiAccountsController::OFFSET", smaller_offset)
        params[:start] = 6
        expect(subject).to eq(ApiAccount.offset(smaller_offset).limit(smaller_offset))
      end

      it 'defaults to 0 if start is negative' do
        params[:start] = -5
        expect(subject.first).to eq(ApiAccount.first)
      end

      it 'defaults to 0 if start is larger than total # of accounts' do
        params[:start] = test_size + 1
        expect(subject.first).to eq(ApiAccount.first)
      end

    end

    context 'when all is specified' do
      it 'loads all api accounts' do
        params[:all] = 'true'
        expect(subject.size).to eq(test_size)
      end

      it 'it loads all even if start is also specified' do
        smaller_offset = 5
        stub_const("Admin::ApiAccountsController::OFFSET", smaller_offset)
        params[:all] = 'true'
        params[:start] = 6
        expect(subject.size).to eq(ApiAccount.count)
      end
    end

  end
end

