require 'spec_helper'

describe FacebookSignedRequestSigninCommand do
  let(:user) { double('user') }
  let(:params) do
    {
        'email' => 'example@greatschools.org',
        'facebook_signed_request' => 123
    }
  end
  subject(:command) do
    command = FacebookSignedRequestSigninCommand.new_from_request_params(params)
  end

  context 'when signed request is not valid' do
    before do
      allow(MiniFB).to receive(:verify_signed_request).
          with(ENV_GLOBAL['facebook_app_secret'], params['facebook_signed_request']).
          and_return(false)
    end
    it 'raises an exception' do
      expect { FacebookSignedRequestSigninCommand.new_from_request_params(params) }.to raise_error
    end
  end

  context 'when signed request is missing' do
    it 'raises an exception' do
      expect(MiniFB).to_not receive(:verify_signed_request)
      expect { FacebookSignedRequestSigninCommand.new_from_request_params({}) }.to raise_error('Facebook signed request invalid')
    end
  end

  describe '#find_or_create_user' do
    context 'when user exists' do
      before do
        expect(MiniFB).to receive(:verify_signed_request).
            with(ENV_GLOBAL['facebook_app_secret'], params['facebook_signed_request']).
            and_return(true)
        allow(command).to receive(:existing_user).and_return(user)
      end
      it 'should return the user' do
        result_user, error, is_new_user = command.find_or_create_user
        expect(result_user).to eq(user)
      end
      it 'should report that user was preexisting' do
        result_user, error, is_new_user = command.find_or_create_user
        expect(is_new_user).to be_falsey
      end
      it 'should not return an error' do
        result_user, error, is_new_user = command.find_or_create_user
        expect(error).to be_nil
      end
    end
    context 'when user does not exist' do
      let(:user) { User.new }
      before do
        expect(MiniFB).to receive(:verify_signed_request).
            with(ENV_GLOBAL['facebook_app_secret'], params['facebook_signed_request']).
            and_return(true)
        allow(user).to receive(:save) { true }
        expect(User).to receive(:new).and_return(user)
      end
      it 'should set the correct email address' do
        allow(command).to receive(:existing_user).and_return(nil)
        result_user, error, is_new_user = command.find_or_create_user
        expect(result_user.email).to eq(params['email'])
      end
      it 'should return a new user' do
        allow(command).to receive(:existing_user).and_return(nil)
        result_user, error, is_new_user = command.find_or_create_user
        expect(result_user).to eq(user)
      end
      it 'should report that user was preexisting' do
        allow(command).to receive(:existing_user).and_return(nil)
        result_user, error, is_new_user = command.find_or_create_user
        expect(is_new_user).to be_truthy
      end
      it 'should not return an error' do
        allow(command).to receive(:existing_user).and_return(nil)
        result_user, error, is_new_user = command.find_or_create_user
        expect(error).to be_nil
      end
      %w[first_name last_name facebook_id].each do |attribute|
        it "should set #{attribute} if provided" do
          params[attribute] = 'Foo'
          allow(command).to receive(:existing_user).and_return(nil)
          result_user, error, is_new_user = command.find_or_create_user
          expect(result_user.send(attribute)).to eq('Foo')
        end
      end
    end
  end
end