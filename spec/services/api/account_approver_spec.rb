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
        allow(Stripe::Subscription).to receive(:create).and_return(nil)
      end
      it 'updates the subscription status to payment failed' do
        approver.approve
        expect(approver.subscription.status).to eq('payment_failed')
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