# encoding: UTF-8
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
      it ' should render correct registration page' do
        get :new, state: school.state, schoolId: school.id
        expect(response).to render_template('osp/registration/new')
      end
    end

    with_shared_context 'Delaware charter school' do
      it ' should render correct registration page' do
        get :new, state: school.state, schoolId: school.id
        expect(response).to render_template('osp/registration/new')
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
      clean_models :gs_schooldb, User, EspMembership, Subscription, User
      clean_models :ca, School
    end

    let(:school) { FactoryGirl.create(:school, id: 1, level_code: 'h', state: 'CA') }
    let(:user) { FactoryGirl.create(:user, email: 'albus@hogwarts.uk') }
    let(:upgrade_osp_user_hash) do
      {state: school.state, schoolId: school.id, email: user.email,
       first_name: 'Albus', last_name: 'Dumbledore',
       school_website: 'www.hogwarts.uk', job_title: 'headmaster'}
    end
    let(:save_new_osp_user_hash) do
      {state: school.state, schoolId: school.id, email: 'minerva@hogwarts.uk', password: user.password,
       first_name: 'Minerva', last_name: 'McGonagall',
       school_website: 'www.hogwarts.uk', job_title: 'headmistress'}
    end

    context 'with a non osp user' do
      before do
        allow_any_instance_of(OspRegistrationController).to receive(:current_user).and_return user
        expect(controller).to receive(:upgrade_user_to_osp_user).and_call_original
        expect(controller).to receive(:sign_up_user_for_subscriptions!)
        get :submit, upgrade_osp_user_hash
        @updated_user = User.where(email: 'albus@hogwarts.uk').first_or_initialize
        @updated_esp_membership = EspMembership.where(member_id: @updated_user.id).first_or_initialize
      end

      it 'should redirect to osp form' do
        expect(response).to redirect_to(osp_page_path(state: school.state, schoolId: school.id, page: 1).sub('/?', '?'))
      end

      user_data = {first_name: 'Albus', last_name: 'Dumbledore', welcome_message_status: 'never_send', how: 'esp'}
      user_data.each do |column, expected_value|
        it "should update the user's #{column}" do
          expect(@updated_user.send(column)).to eq expected_value
        end
      end

      esp_membership_data = {state: 'CA', school_id: 1, job_title: 'headmaster', web_url: 'www.hogwarts.uk',
                             status: 'provisional', active: false}
      esp_membership_data.each do |column, expected_value|
        it "should update esp_membership #{column}" do
          expect(@updated_esp_membership.send(column)).to eq expected_value
        end
      end
    end

    context 'with a non osp user with bad data posted' do
      victim_attrs = {email: 'victim@hogwarts.uk', password: 'victim_pass'}
      victim_membership_attrs = { job_title: 'the principle', state: 'de', school_id: 2 }
      let!(:victim) { FactoryGirl.create(:user, victim_attrs) }
      let!(:victim_membership) { FactoryGirl.create(:esp_membership, victim_membership_attrs.merge(member_id: victim.id)) }
      let(:bad_upgrade_osp_user_hash) do
        {state: school.state, schoolId: school.id, email: victim.email, password: 'new_password',
         first_name: 'Albus', last_name: 'Dumbledore',
         school_website: 'www.hogwarts.uk', job_title: 'headmaster'}
      end

      before do
        allow_any_instance_of(OspRegistrationController).to receive(:current_user).and_return user
        expect(controller).to receive(:upgrade_user_to_osp_user).and_call_original
        expect(controller).to receive(:sign_up_user_for_subscriptions!)
        get :submit, bad_upgrade_osp_user_hash
        @victim = User.where(email: victim.email).first
        @victim_membership = EspMembership.where(member_id: @victim.id).first
      end

      it 'should redirect to osp form' do
        expect(response).to redirect_to(osp_page_path(state: school.state, schoolId: school.id, page: 1).sub('/?', '?'))
      end

      victim_attrs.each do |column, expected_value|
        it "should not update the victim's #{column}" do
          expect(@victim[column].to_s).to include(expected_value.to_s)
        end
      end

      victim_membership_attrs.each do |column, expected_value|
        it "should not update the victim's membership's #{column}" do
          expect(@victim_membership.send(column)).to eq expected_value
        end
      end
    end

    context 'should register new osp user' do
      before do
        expect(controller).to receive(:save_new_osp_user).and_call_original
        expect(controller).to receive(:sign_up_user_for_subscriptions!)
        get :submit, save_new_osp_user_hash
        @updated_user = User.where(email: 'minerva@hogwarts.uk').first_or_initialize
        @updated_esp_membership = EspMembership.where(member_id: @updated_user.id).first_or_initialize
      end
      it 'should redirect to osp form' do
        expect(response).to redirect_to(osp_confirmation_path(state: school.state, schoolId: school.id))
      end

      user_data = {first_name: 'Minerva', last_name: 'McGonagall', welcome_message_status: 'never_send', how: 'esp'}
      user_data.each do |column, expected_value|
        it "should update the user's #{column}" do
          expect(@updated_user.send(column)).to eq expected_value
        end
      end

      esp_membership_data = {state: 'CA', school_id: 1, job_title: 'headmistress', web_url: 'www.hogwarts.uk',
                             status: 'provisional', active: false}
      esp_membership_data.each do |column, expected_value|
        it "should update esp_membership #{column}" do
          expect(@updated_esp_membership.send(column)).to eq expected_value
        end
      end
    end

    context 'when creating a new user and trying to use an existing account ' do
      victim_attrs = { email: 'victim@hogwarts.uk', password: 'victim_pass'}
      victim_membership_attrs = { job_title: 'the principle', state: 'de', school_id: 2 }
      let!(:victim) { FactoryGirl.create(:user, victim_attrs) }
      let!(:victim_membership) { FactoryGirl.create(:esp_membership, victim_membership_attrs.merge(member_id: victim.id)) }
      let(:bad_save_new_osp_user_hash) do
        {state: school.state, schoolId: school.id, email: victim.email, password: 'new_password',
         first_name: 'Minerva', last_name: 'McGonagall',
         school_website: 'www.hogwarts.uk', job_title: 'headmistress'}
      end
      before do
        expect(controller).to receive(:save_new_osp_user).and_call_original
        get :submit, bad_save_new_osp_user_hash
        @victim = User.where(email: victim.email).first
        @victim_membership = EspMembership.where(member_id: @victim.id).first
      end

      victim_attrs.each do |column, expected_value|
        it "should not update the victim's #{column}" do
          expect(@victim[column].to_s).to include(expected_value.to_s)
        end
      end

      victim_membership_attrs.each do |column, expected_value|
        it "should not update the victim's membership's #{column}" do
          expect(@victim_membership.send(column)).to eq expected_value
        end
      end
    end

    [
      {school_website: 'www.hogwarhogwarhogwarhogwarhogwarttttthogwarthogwarthogwarthogwarthogwarthogwarthogwarthogwarthogwartssssssssshogwarts.uk'},
      {school_website: 'www.badguys.ru'},
      {school_website: 'www.badguys.pl'},
      {email: 'keith@badguys.ru'},
      {email: 'keith@badguys.pl'},
      {school_website: "http://ищукран.рф/online/art/994-polovoy-chlen-golovka/"},
    ].each do |bad_params|
      context "with bad params: #{bad_params}" do
        let(:super_long_school_website_params) do
          save_new_osp_user_hash.merge(bad_params)
        end

        it 'should redirect back to NEW with a flash' do
          expect(controller).to receive(:flash_notice)
          get :submit, super_long_school_website_params
          expect(response).to render_template('osp/registration/new')
        end
      end
    end

    [
      'www.hogwarts.uk',
      '',
      'http://\\\\\\/\/\/@#$%$!@#%#^$%&$^#%@$$$^%&^@#@#%@#%!\\\\\\',
    ].each do |website|
      context "with website: #{website}" do
        it 'should save the website correctly' do
          get :submit, save_new_osp_user_hash.merge(school_website: website)
          user = User.where(email: 'minerva@hogwarts.uk').first
          membership = EspMembership.where(member_id: user.id).first
          expect(membership.web_url).to eq(website)
        end
      end
    end

    context 'when submitting user params that will fail mysql validation' do
      let(:invalid_user_params) do
        {state: school.state, schoolId: school.id, email: user.email,
         first_name: 'Albus', last_name: 'Dumbledore',
         school_website: 'www.hogwarts.uk', job_title: 'headmaster',
         password: 'thispasswordistoolong', password_verify: 'thispasswordistoolong'
        }
      end

      it 'should render new template with a school object' do
        allow_any_instance_of(OspRegistrationController).to receive(:current_user)
        post :submit, invalid_user_params
        expect(controller.instance_variable_get(:@school)).to_not be_nil
        expect(response).to render_template('osp/registration/new')
      end
    end

    let(:invalid_esp_membership_params) do
      {state: school.state, schoolId: school.id, email: user.email,
       first_name: 'Albus', last_name: 'Dumbledore',
       school_website: 'www.thisistoolongthisistoolongthisistoolongthisistoolongthisistoolongthisistoolongthisistoolongthisistoolong.uk', job_title: 'headmaster',
       password: 'ravenclaw', password_verify: 'ravenclaw'
      }
    end

    context 'when submitting esp_membershp params that will fail mysql validation' do
      it 'should render new template with a school object' do
        allow_any_instance_of(OspRegistrationController).to receive(:current_user)
        post :submit, invalid_esp_membership_params
        expect(controller.instance_variable_get(:@school)).to_not be_nil
        expect(response).to render_template('osp/registration/new')
      end
    end

    context 'when submitting params without a school' do
      it 'should render the no school selected template' do
        post :submit
        expect(response).to render_template('osp/registration/no_school_selected')
      end
    end

    context 'when submitting params without a school_website' do
      it 'should render the new template' do
        post :submit, invalid_esp_membership_params.reject {|k,v| k == :school_website}
        expect(response).to render_template('osp/registration/new')
      end
    end
  end

  describe '#sign_up_user_for_subscriptions!' do
    after(:all) do
      clean_models :ca, School
    end

    after(:each) do
      clean_models :gs_schooldb, Subscription, User
    end

    shared_examples_for 'a robust osp subscription signup process' do
      let(:current_subscriptions) { user.subscriptions }
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
          expect(user.subscriptions).to eq(current_subscriptions)
        end
      end
    end

    context "with a user who has already signed up" do
      it_behaves_like 'a robust osp subscription signup process' do
        let(:user) { FactoryGirl.create(
            :user,
            :with_school_subscriptions,
            lists: ['mystat', 'osp', 'osp_partner_promos'],
            lists_schools: [school, school, school],
            email: 'km@gs.org'
          )
        }
      end
    end

    context "with a user who has not signed up" do
      it_behaves_like 'a robust osp subscription signup process' do
        let(:user) { FactoryGirl.create(:user, email: 'km2@gs.org') }
      end
    end
  end
end
