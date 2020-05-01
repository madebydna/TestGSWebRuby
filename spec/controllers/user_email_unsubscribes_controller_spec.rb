require 'spec_helper'

describe UserEmailUnsubscribesController do

  # after { clean_dbs(:gs_schooldb) }

  # describe '#new' do
  #   it 'should redirect to signin page if not user not signed' do
  #     get :new
  #     expect(response).to redirect_to(signin_path)
  #   end
  #   context 'with valid token' do
  #     it 'assigns @page_name' do
  #       valid_token = stub_valid_token
  #       page_name = 'User Email Unsubscribe'
  #       get :new, {token: valid_token }
  #       expect(assigns(:page_name)).to eq(page_name)
  #     end
  #     it 'should render page' do
  #       valid_token = stub_valid_token
  #       get :new, {token: valid_token }
  #       expect(response).to render_template('new')
  #     end
  #   end
  #   context 'with invalid token' do
  #     it 'should redirect to singin url' do
  #       invalid_token = stub_invalid_token
  #       get :new, {token: invalid_token }
  #       expect(response).to redirect_to(signin_path)
  #     end
  #   end
  # end

  # describe '#edit' do
  #   it 'should redirect to signin page if not user not signed' do
  #     post :create
  #     expect(response).to redirect_to(signin_path)
  #   end

  #   it "unsubscribes user from all subscriptions" do
  #     current_user = stub_current_user
  #     subscription_manager = stub_user_subscription_manager
  #     expect(UserSubscriptionManager).to receive(:new).with(current_user)
  #     expect(subscription_manager).to receive(:unsubscribe)
  #     post :create
  #   end
  # end

  # def stub_valid_token
  #   user = FactoryBot.create(:user, id: 1)
  #   UserVerificationToken.token(user.id)
  # end

  # def stub_invalid_token
  #   FactoryBot.create(:user, id: 1)
  #   'invalid_token'
  # end

  # def stub_user_subscription_manager
  #   user_subscription_manager_class = double
  #   stub_const('UserSubscriptionManager', user_subscription_manager_class)
  #   spy("subscription_manager").tap do |updater|
  #     allow(updater).to receive(:update_state)
  #     allow(user_subscription_manager_class).to receive(:new).and_return(updater)
  #   end
  # end

  # def stub_current_user
  #   user = FactoryBot.create(:user, id: 1)
  #   allow(controller).to receive(:current_user).and_return user
  #   user
  # end
end
