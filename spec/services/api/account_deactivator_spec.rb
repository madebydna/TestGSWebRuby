require "spec_helper"

describe Api::AccountDeactivator do

  describe '#process' do
    let(:user) { create(:api_user, stripe_customer_id: 1) }
    let(:subscription) { create(:api_subscription, user: user, stripe_id: '123') }
    let(:deactivator) { Api::AccountDeactivator.new(subscription.id) }

    context 'subscription is cancelled successfully in stripe' do
      before do
        stripe_double = double
        allow(Stripe::Subscription).to receive(:delete).and_return(stripe_double)
      end

      it 'updates the subscription status to payment successful' do
        deactivator.process
        expect(deactivator.subscription.status).to eq('bizdev_deactivated')
      end

      it 'sends an email to the user' do
        expect(deactivator).to receive(:email_user)
        deactivator.process
      end

      it 'sends an email to bizdev' do
        expect(deactivator).to receive(:email_biz_dev)
        deactivator.process
      end
    end

    context 'subscription fails to cancel in stripe' do
      before do
        @stripe_exception = Stripe::InvalidRequestError.new("subscription not found", {})
        allow(Stripe::Subscription).to receive(:delete)
                                         .with(subscription.stripe_id)
                                         .and_raise(@stripe_exception)
      end

      it 'updates the subscription status_message to the returning error' do
        deactivator.process
        expect(deactivator.subscription.status_message).to eq(@stripe_exception.message)
      end

      it 'sends an email to the user' do
        expect(deactivator).to receive(:email_user)
        deactivator.process
      end

      it 'sends an email to bizdev' do
        expect(deactivator).to receive(:email_biz_dev)
        deactivator.process
      end
    end
  end

end