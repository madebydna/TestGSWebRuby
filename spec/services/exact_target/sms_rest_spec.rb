require 'spec_helper'
require 'exact_target'

describe ExactTarget::SmsRest do

  let(:sms_rest_calls) { double }
  before do
    stub_sms_rest_calls_class
    stub_auth_token_manager
  end

  subject { ExactTarget::SmsRest.new.test_method('blah') }
  context 'with failed authentication token' do
    before { stub_failure_of_first_authentication_token }
    context 'with second authentication token valid' do
      it 'call method with new token' do
        expect(sms_rest_calls).to receive(:send).with(:test_method, 'new_token', 'blah')
        subject
      end
    end

    context 'with second authentication failing' do
      let(:gs_logger) { double }
      it 'should log and raise error' do
        stub_failure_of_second_authentication_token
        expect(GSLogger).to receive(:error)
        expect{ subject }.to raise_error(GsExactTargetAuthorizationError)
      end
    end
  end

  context 'with valid authentication token' do
    it 'send method' do
      expect(sms_rest_calls).to receive(:send).with(:test_method, 'token', 'blah')
      subject
    end
  end

  def stub_failure_of_second_authentication_token
    allow(sms_rest_calls).to receive(:send).with(:test_method, 'new_token', 'blah').and_raise(GsExactTargetAuthorizationError)
  end

  def stub_failure_of_first_authentication_token
    allow(sms_rest_calls).to receive(:send).with(:test_method, 'token', 'blah').and_raise(GsExactTargetAuthorizationError)
  end

  def stub_sms_rest_calls_class
    allow(ExactTarget::SmsRestCalls).to receive(:new).and_return(sms_rest_calls)
    allow(ExactTarget::SmsRestCalls).to receive(:instance_methods).with(false).and_return([:test_method])
  end

  def stub_auth_token_manager
    allow(ExactTarget::AuthTokenManager).to receive(:fetch_access_token).and_return('token')
    allow(ExactTarget::AuthTokenManager).to receive(:fetch_new_access_token).and_return('new_token')
  end
end

