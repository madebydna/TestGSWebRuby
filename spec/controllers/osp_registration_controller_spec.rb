require 'spec_helper'
require 'controllers/contexts/osp_shared_contexts'
require 'features/contexts/osp_contexts.rb'

describe OspRegistrationController do
  describe '#new' do
    it 'should have correct osp page meta tag' do
      allow(controller).to receive(:set_meta_tags)
    end

    it 'should have correct omniture tracking' do
      allow(controller).to receive(:set_omniture_data_for_school)
      allow(controller).to receive(:set_omniture_data_for_user_request)
    end

    with_shared_context 'visit registration page with no state or school' do
      it ' should render correct error page' do
        expect(response).to render_template('osp/registration/no_school_selected')
      end
    end

    with_shared_context 'Delaware public school' do
      with_shared_context 'visit registration page as a public or charter DE as a not signed in osp user' do
        it ' should render correct error page' do
          expect(response).to render_template('osp/registration/delaware')
        end
      end
    end

    with_shared_context 'Delaware charter school' do
      with_shared_context 'visit registration page as a public or charter DE as a not signed in osp user' do
        it ' should render correct error page' do
          expect(response).to render_template('osp/registration/delaware')
        end
      end
    end

    with_shared_context 'Delaware private school' do
      with_shared_context 'visit registration page with school state and school' do
        it ' should render correct registration page' do
          expect(response).to render_template('osp/registration/new')
        end
      end
    end

    with_shared_context 'Basic High School' do
      with_shared_context 'visit registration page with school state and school' do
        it ' should render correct registration page' do
          expect(response).to render_template('osp/registration/new')
        end
      end
    end

    # with_shared_context 'Basic High School' do
    #   with_shared_context 'signed in approved osp user for school' do
    #     with_shared_context 'visit registration page with school state and school' do
    #       it 'should redirect osp user to school osp form' do
    #         expect(response).to render_template(osp_page_path(page: 1, schoolId: school.id, state: school.state))
    #       end
    #     end
    #   end
    # end

    #TODO: finish this test when official-school-profile/dashboard is a ruby page
    # with_shared_context 'Basic High School' do
    #   with_shared_context 'signed in approved osp user for school' do
    #     with_shared_context 'visit registration page with school state and school' do
    #       it 'should redirect osp user to school osp form' do
    #         save_and_open_page
    #         expect(response).to redirect_to('/official-school-profile/dashboard/')
    #       end
    #     end
    #   end
    # end

  end

  describe '#sign_up_user_for_subscriptions!' do
    after do
      clean_models :ca, School
      clean_models :gs_schooldb, Subscription
    end

    let(:user) { FactoryGirl.build(:user) }
    let(:school) { FactoryGirl.create(:school) }

    context 'with both opt-ins selected' do
      let(:subscription_params) { ['mystat_osp', 'osp_partner_promos'] }

      before do
        controller.send(:sign_up_user_for_subscriptions!, user, school, subscription_params)
      end

      %w(mystat osp osp_partner_promos).each do |list|
        it "should sign up the user for #{list}" do
          expect(user.has_subscription?(list, school)).to be true
        end
      end
    end

    context 'with the osp_parter_promos opt-in selected' do
      let(:subscription_params) { ['osp_partner_promos'] }

      before do
        controller.send(:sign_up_user_for_subscriptions!, user, school, subscription_params)
      end

      %w(osp_partner_promos).each do |list|
        it "should sign up the user for #{list}" do
          expect(user.has_subscription?(list, school)).to be true
        end
      end
    end

    context 'with the mystat_osp opt-in selected' do
      let(:subscription_params) { ['mystat_osp'] }

      before do
        controller.send(:sign_up_user_for_subscriptions!, user, school, subscription_params)
      end

      %w(mystat osp).each do |list|
        it "should sign up the user for #{list}" do
          expect(user.has_subscription?(list, school)).to be true
        end
      end
    end

    context 'with no opt-in selected' do
      let(:subscription_params) { [] }

      before do
        controller.send(:sign_up_user_for_subscriptions!, user, school, subscription_params)
      end

      it "should sign up the user for no lists" do
        expect(user.subscriptions).to be_empty
      end
    end
  end
end
