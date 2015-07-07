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

    it 'should render correct error page with no state or school' do
      get :new
      expect(response).to render_template('osp/registration/no_school_selected')
    end

    with_shared_context 'Delaware public school' do
      it ' should render correct error page' do
        get :new, state: school.state, schoolId: school.id
        expect(response).to render_template('osp/registration/delaware')
      end
    end

    with_shared_context 'Delaware charter school' do
      it ' should render correct error page' do
        get :new, state: school.state, schoolId: school.id
        expect(response).to render_template('osp/registration/delaware')
      end
    end

    with_shared_context 'Delaware private school' do
      it ' should render correct registration page' do
        get :new, state: school.state, schoolId: school.id
        expect(response).to render_template('osp/registration/new')
        end
    end

    with_shared_context 'Basic High School' do
      it ' should render correct registration page' do
        get :new, state: school.state, schoolId: school.id
        expect(response).to render_template('osp/registration/new')
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

  describe '#submit' do
    after do
      clean_models :gs_schooldb, User, EspMembership
      clean_models :ca, School
    end

    let(:user) { FactoryGirl.create(:user) }
    let(:esp_membership) { FactoryGirl.build(:esp_membership) }
    let(:upgrade_osp_user_hash) {{ state: school.state, schoolId: school.id, email: user.email,
                                  first_name: user.first_name, last_name: user.last_name,
                                  school_website: 'foo.com', job_title: 'ping pong master', esp_membership: esp_membership.member_id }}
    let(:save_new_osp_user_hash) {{ state: school.state, schoolId: school.id, email: user.email, password: user.password,
                                    first_name: user.first_name, last_name: user.last_name,
                                    school_website: 'foo.com', job_title: 'ping pong master', esp_membership: esp_membership.member_id}}

    with_shared_context 'Basic High School' do
        it 'should upgrade regular user to osp user' do
          allow_any_instance_of(OspRegistrationController).to receive(:current_user).and_return user
          expect(controller).to receive(:upgrade_user_to_osp_user).and_call_original
          expect(controller).to receive(:sign_up_user_for_subscriptions!)
          get :submit, upgrade_osp_user_hash
          expect(response).to redirect_to(osp_page_path(state: school.state, schoolId: school.id, page: 1).sub('/?', '?'))
          expect(EspMembership.count).to_not be 0
          # todo: test for user row saving
          # expect(User.job_title).to be 'ping pong master'
        end

        # it 'should register new osp user' do
        #   # allow_any_instance_of(OspRegistrationController).to receive(:user).and_return user
        #   expect(controller).to receive(:save_new_osp_user)
        #   get :submit, save_new_osp_user_hash
        #   expect(response.redirect_url).to eq(osp_confirmation_url(state: school.state, schoolId: school.id))
        #   expect(EspMembership.count).to_not be 0
        #   expect(User.count).to_not be 0
        # end
    end
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
