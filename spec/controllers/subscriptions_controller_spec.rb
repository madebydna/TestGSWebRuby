require 'spec_helper'

describe SubscriptionsController do

  after do
    clean_models :gs_schooldb, User, Subscription
    clean_models :ca, School
  end

  describe '#create' do
    let(:subscription_params){{test: 'param'}}
    let(:referrer) {'www.greatschools.org/blah'}

    context 'when logged in' do
      before do
        allow(controller).to receive(:logged_in?).and_return(true)
        allow(controller).to receive(:create_subscription)
        request.env['HTTP_REFERER'] = referrer
      end

      context 'without ajax' do
        before { allow(controller).to receive(:ajax?).and_return(false) }
        it 'should create subcription with params' do
          expect(controller).to receive(:create_subscription).
            with(subscription_params)
          post :create, subscription: subscription_params
        end
        it 'should redirect back to referrer' do
          result = post :create, subscription: subscription_params
          expect(result).to redirect_to(referrer)
        end
      end
      #
      context 'with ajax' do
        before do
          allow(controller).to receive(:ajax?).and_return(true)
          allow(controller).to receive(:render)
        end
        it 'should create subcription with params' do
          expect(controller).to receive(:create_subscription).with(subscription_params)
          post :create,  subscription: subscription_params
        end
        it 'render json response with status 200' do
          render_response = {:json=>{}, :status=>200}
          expect(controller).to receive(:render).with(render_response)
          post :create,  subscription: subscription_params
        end
      end
    end

    context 'when logged out' do
      before do
        allow(controller).to receive(:log_in_required_message).and_return('error')
        allow(controller).to receive(:logged_in?).and_return(false)
        allow(controller).to receive(:create_subscription)
        allow(controller).to receive(:join_url).and_return('join_url')
      end

      context 'without ajax' do
        before { allow(controller).to receive(:ajax?).and_return(false) }
        it 'should saved_deferred action with create_subscription_deferred and subscription params' do
          expect(controller).to receive(:save_deferred_action).
            with(:create_subscription_deferred, subscription_params)
          post :create,  subscription: subscription_params
        end
        it 'should flash error message' do
          expect(controller).to receive(:flash_error).with('error')
          post :create,  subscription: subscription_params
        end
        it 'should redirect to join_url' do
          result = post :create, subscription: subscription_params
          expect(result).to redirect_to('join_url')
        end
      end

      context 'with ajax' do
        before do
          allow(controller).to receive(:ajax?).and_return(true)
          allow(controller).to receive(:render)
        end
        it 'render json response with error and status 422' do
          render_response = {:json=>{error: 'error'}, :status=>422}
          expect(controller).to receive(:render).with(render_response)
          post :create,  subscription: subscription_params
        end
      end
    end
  end

  describe '#destroy' do
    let!(:current_user) { FactoryBot.create(:user,:with_subscriptions,:list=>'osp') }

    before do
      controller.instance_variable_set(:@current_user, current_user)
    end

    it 'should not call subscription.find since there are no params' do

      allow(controller).to receive(:params).and_return({})

      expect(Subscription).to_not receive(:find)
      controller.send :destroy
    end

    it "should not change the subscription count since the subscription does not match user's subscriptions" do

      some_subscription = FactoryBot.create(:subscription,id:15)
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
