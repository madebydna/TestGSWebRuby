require 'spec_helper'

describe Admin::ApiAccountsController do

  describe '#display_selected_api_accounts' do
    let (:params) {
      {all: 'true'}
    }

    let (:subject) { controller.send(:index) }

    before do
      allow(controller).to receive(:params).and_return(params)
    end

    describe 'calls the main pagination method' do
      it { should receive(:display_selected_api_accounts)}
    end


  end
end