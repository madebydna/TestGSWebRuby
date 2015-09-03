require 'spec_helper'

describe SubscriptionsController do

  after do
    clean_models :gs_schooldb, User, Subscription 
    clean_models :ca, School
  end

  describe '#attempt_sign_up' do
    let(:subscription_params){{test: 'param'}}
    context 'without ajax' do
      before do
       allow(controller).to receive(:redirect_back_or_default)
      end
      context 'with specific redirect path' do
        let(:redirect_path) { 'redirect_path' }
        let(:subject) { controller.send :attempt_sign_up, subscription_params, redirect_path }
        it 'should create subcription with params' do
          expect(controller).to receive(:create_subscription).with(subscription_params)
          subject
        end
        it 'should redirect back to specified redirect path' do
          expect(controller).to receive(:redirect_back_or_default).with(redirect_path)
          subject
        end
      end

      context 'without specific redirect path' do
        let(:subject) { controller.send :attempt_sign_up, subscription_params }
        it 'should create subcription with params' do
          expect(controller).to receive(:create_subscription).with(subscription_params)
          subject
        end
        it 'should redirect back without specific path' do
          expect(controller).to receive(:redirect_back_or_default).with(no_args)
          subject
        end
      end
    end

    context 'with ajax' do
      before do
       allow(controller).to receive(:render)
       allow(controller).to receive(:redirect_back_or_default)
       allow(controller).to receive(:ajax?).and_return(true)
      end
        let(:subject) { controller.send :attempt_sign_up, subscription_params }
        it 'should create subcription with params' do
          expect(controller).to receive(:create_subscription).with(subscription_params)
          subject
        end
        it 'should render with error message' do
          render_response = {:json=>{}, :status=>200}
          expect(controller).to receive(:render).with(render_response)
          subject
        end

    end
  end

  describe '#handle_not_logged_in' do
    before do
      allow(controller).to receive(:log_in_required_message).and_return('error')
    end
    let(:subscription_params){{test: 'param'}}
    let(:subject) { controller.send :handle_not_logged_in, subscription_params }
    context 'with not ajax' do
     before do
       allow(controller).to receive(:redirect_to)
       allow(controller).to receive(:ajax?).and_return(false)
       allow(controller).to receive(:join_url).and_return('join_url')
     end
      it 'should saved deferred create_subscription deffered actions with subscription params' do
        expect(controller).to receive(:save_deferred_action).
          with(:create_subscription_deferred, subscription_params)
        subject
      end
      it 'should flash error message' do
        expect(controller).to receive(:flash_error).with('error')
        subject
      end
      it 'should redirect to join_url' do
        expect(controller).to receive(:redirect_to).with('join_url')
        subject
      end
    end
    context 'with ajax' do
     before do
       allow(controller).to receive(:redirect_to)
       allow(controller).to receive(:ajax?).and_return(true)
       allow(controller).to receive(:join_url).and_return('join_url')
     end
      it 'should render with error message' do
        render_response = {:json=>{:error=>"error"}, :status=>422}
        expect(controller).to receive(:render).with(render_response)
        subject
      end
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
