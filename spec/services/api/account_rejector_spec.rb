require "spec_helper"

describe Api::AccountDeactivator do

  describe '#process' do
    let(:user) { create(:api_user, stripe_customer_id: 1) }
    let(:subscription) { create(:api_subscription, user: user, stripe_id: '123') }
    let(:rejector) { Api::AccountRejector.new(subscription.id) }

    describe "#process" do
      it ' updates the subscription status to biz dev rejected' do
        rejector.process
        expect(rejector.subscription.status).to eq('bizdev_rejected')
      end
    end
  end
end