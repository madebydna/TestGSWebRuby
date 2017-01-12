require 'spec_helper'
require 'controllers/contexts/osp_shared_contexts'

describe OspLandingController do
  #include ActionView::Helpers::TranslationHelper

  describe '#dashboard' do
    it 'redirects to signin if no user' do
      get :dashboard
      expect(response).to redirect_to(signin_path)
    end

    context 'with a signed in user with no memberships' do
      let (:user) { FactoryGirl.create(:user) }
      after { clean_models User }
      before { allow(controller).to receive(:current_user).and_return(user) }

      it 'redirects to my account' do
        get :dashboard
        expect(response).to redirect_to(my_account_path)
      end
    end

    context 'when provided a state and schoolId parameter' do
      let (:user) { FactoryGirl.create(:user) }
      after { clean_models User }
      before { allow(controller).to receive(:current_user).and_return(user) }

      it 'redirects to the appropriate form page' do
        get :dashboard, state: 'ca', schoolId: 1
        expect(response).to redirect_to(osp_page_path(:state =>'ca', :schoolId => 1, :page => 1))
      end
    end

    with_shared_context 'user esp_membership status is', :approved do
      before { allow(controller).to receive(:current_user).and_return(current_user) }

      it 'approved, it redirects to appropriate form page' do
        get :dashboard
        expect(response).to redirect_to(osp_page_path(:state =>state, :schoolId => school_id, :page => 1))
      end
    end

    with_shared_context 'user esp_membership status is', :provisional do
      before { allow(controller).to receive(:current_user).and_return(current_user) }

      it 'provisional, it redirects to appropriate form page' do
        get :dashboard
        expect(response).to redirect_to(osp_page_path(:state =>state, :schoolId => school_id, :page => 1))
      end
    end
  end
end