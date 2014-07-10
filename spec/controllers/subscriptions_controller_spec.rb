require 'spec_helper'

describe SubscriptionsController do

  describe '#attempt_sign_up' do

    # it 'should create the subscription ' do
    #   expect(controller).should_receive(1)
    #
    # end
    let(:response) { get :join }

    it 'should redirect to join url' do

      allow(controller).to receive(:logged_in?).and_return(nil)
      allow(controller).to receive(:join_url).and_return('cliu.greatschools.org')

      expect(controller).to receive(:save_deferred_action)
      expect(controller).to receive(:redirect_to).with('cliu.greatschools.org')
      controller.send :attempt_sign_up, '',''

    end
  end

  # describe '#log_in_required_message' do
  #   expect(controller).should_receive(:default)
  #   get 'Please log in or register your email in order to receive updates.'
  # end
end