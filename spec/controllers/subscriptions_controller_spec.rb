require 'spec_helper'

describe SubscriptionsController do

  after do
    clean_models :gs_schooldb,User, Subscription
  end

  describe '#attempt_sign_up' do


    let(:response) { get :join }

    it 'should redirect to join url' do

      allow(controller).to receive(:logged_in?).and_return(nil)
      allow(controller).to receive(:join_url).and_return('cliu.greatschools.org')

      expect(controller).to receive(:save_deferred_action)
      expect(controller).to receive(:redirect_to).with('cliu.greatschools.org')
      controller.send :attempt_sign_up, '',''

    end
  end

  describe '#destroy' do
    let!(:current_user) { FactoryGirl.create(:user,:with_subscriptions,:list=>'osp') }

    before do
      controller.instance_variable_set(:@current_user, current_user)
    end

    it 'should not call subscription.find since there are no params' do

      allow(controller).to receive(:params).and_return({})

      expect(Subscription).to_not receive(:find)
      controller.send :destroy
    end

    it "should not change the subscription count since the subscription does not match user's subscriptions" do

      some_subscription = FactoryGirl.create(:subscription,id:15)
      allow(controller).to receive(:params).and_return({id: 15})
      allow(Subscription).to receive(:find).and_return(some_subscription)

      expect {
        controller.send :destroy
        current_user.reload
      }.to_not change(current_user.subscriptions, :count)

    end

    it 'should delete the user subscription' do

      first_subscription = current_user.subscriptions[0]
      allow(controller).to receive(:params).and_return({id: first_subscription.id})
      allow(Subscription).to receive(:find).and_return(first_subscription)

      expect {
        controller.send :destroy
        current_user.reload
      }.to change(current_user.subscriptions, :count).by(-1)

    end
  end


end