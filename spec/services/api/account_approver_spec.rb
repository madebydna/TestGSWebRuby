require "spec_helper"

describe Api::AccountApprover do

  describe '#approve' do
    let(:user) { create(:api_user, stripe_customer_id: 1) }
    let(:subscription) { create(:api_subscription, user: user) }
    let(:approver) { Api::AccountApprover.new(subscription) }

    it 'initially updates the subscription status to biz dev approved' do
      allow(approver).to receive(:create_stripe_subscription)
      allow(approver).to receive(:subscription).and_return(subscription)
      approver.approve
      expect(approver.subscription.status).to eq('bizdev_approved')
    end

    context 'payment processes successfully' do
      before do
        stripe_double = double
        allow(Stripe::Subscription).to receive(:create).and_return(stripe_double)
        allow(stripe_double).to receive(:id).and_return(1)
      end

      it 'updates the subscription status to payment successful' do
        approver.approve
        expect(approver.subscription.status).to eq('payment_succeeded')
      end

      it 'sends an email to the user' do
        expect(approver).to receive(:email_user)
        approver.approve
      end

      it 'sends an email to bizdev' do
        expect(approver).to receive(:email_biz_dev)
        approver.approve
      end
    end

    context 'payment fails' do
      before do
        @stripe_exception = Stripe::InvalidRequestError.new("no payment attached", {})
        allow(Stripe::Subscription).to receive(:create)
                                         .with({:customer=>"1", :items=>[{:price=>nil}]})
                                         .and_raise(@stripe_exception)
      end

      it 'updates the subscription status to payment failed and attaches the failure message' do
        approver.approve
        expect(approver.subscription.status).to eq('payment_failed')
        expect(approver.subscription.status_message).to eq(@stripe_exception.message)
      end

      it 'sends an email to the user' do
        expect(approver).to receive(:email_user)
        approver.approve
      end

      it 'sends an email to bizdev' do
        expect(approver).to receive(:email_biz_dev)
        approver.approve
      end
    end
  end

end