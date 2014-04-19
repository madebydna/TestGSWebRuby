require 'spec_helper'
require 'controllers/concerns/authentication_concerns_spec'

describe SigninController do

  it { should respond_to :new }

  it_behaves_like 'controller with authentication'

  describe '#store_location' do
    it 'should store_location when #new method called on controller' do
      expect(controller).to receive(:has_stored_location?).and_return(false)
      expect(controller).to receive(:store_location)
      get :new
    end
  end

  describe '#create' do

    describe 'authenticate' do
      it 'should call authenticate if post contained password info' do
        expect(controller).to receive(:authenticate).and_return([nil, 'reject'])
        get :create, password: 'abc'
      end

      context 'authentication error' do
        before do
          expect(controller).to receive(:authenticate).and_return([nil, 'reject'])
          expect(controller).to receive(:flash_error).with('reject')
        end

        it 'should flash the error if one occurs' do
          get :create, password: 'abc'
        end

        it 'should redirect if an error occurs' do
          expect(get :create, password: 'abc').to redirect_to(signin_url(only_path: true))
        end
      end

      context 'successful login' do
        let(:user) { mock_model(User) }

        before do
          expect(controller).to receive(:authenticate).and_return([user, nil])
        end

        it 'should log the user in' do
          expect(controller).to receive(:log_user_in).with(user)
          get :create, password: 'abc'
        end
      end
    end

    describe 'register' do

      after(:all) do
        clean_dbs :gs_schooldb
      end

      it 'should register new user if no password provided' do
        pending 'fix'
        get :create, email: 'blah@example.com'
      end

      context 'registration error' do
        before do
          expect(controller).to receive(:register).and_return([nil, 'reject'])
          expect(controller).to receive(:flash_error).with('reject')
        end

        it 'should flash the error if one occurs' do
          get :create, email: 'blah@example.com'
        end

        it 'should redirect if an error occurs' do
          expect(get :create, email: 'blah@example.com').to redirect_to(signin_url(only_path: true))
        end
      end

      context 'successful registration' do
        let(:user) { mock_model(User) }
        before do
          expect(controller).to receive(:register).and_return([user, nil])
        end

        it 'should tell the user what to do next' do
          expect(controller).to receive(:flash_notice)
          get :create, email: 'blah@example.com'
        end

        it 'should set the current user to the newly created user' do
          post :create, email: 'blah@example.com'
          expect(controller.send :current_user).to eq(user)
        end
      end
    end

  end

  describe '#destroy' do
    subject { get :destroy }

    it 'should sign the user out' do
      expect(controller).to receive(:log_user_out)
      get :destroy
    end

    it 'should notify the user of logout' do
      expect(controller).to receive(:flash_notice)
      get :destroy
    end

    it 'should redirect the user to signin form if there is no http referrer' do
      expect(subject).to redirect_to(signin_url(host: request.host, trailing_slash: true))
      get :destroy
    end

    it 'should redirect the user back if there is a http referrer' do
      referrer = 'www.greatschools.org/blah'
      request.env['HTTP_REFERER'] = referrer
      expect(subject).to redirect_to(referrer)
      get :destroy
    end
  end

  describe '#authenticate' do
    let(:user) { mock_model(User) }

    it 'should return an existing user if one exists and it matches given password' do
      expect(User).to receive(:with_email).and_return(user)
      expect(user).to receive(:password_is?).and_return(true)
      expect(controller).to receive(:params).and_return({ email: 'blah@example.com' }).twice
      expect(controller.send :authenticate).to eq([ user, nil ])
    end
  end

  describe '#verify_email' do
    let(:user) { FactoryGirl.build(:user) }
    let(:token) { EmailVerificationToken.new(user: user) }
    let(:expired_token) { 
      EmailVerificationToken.new(user: user, time: 1000.years.ago)
    }
    let(:valid_params) {
      {
        id: token.generate,
        time: token.time_as_string
      }
    }

    shared_examples_for 'something went wrong' do
      it 'should flash an error message' do
        expect(controller).to receive(:flash_error) 
        subject
      end

      it 'should redirect to join page' do
        expect(subject).to redirect_to join_url
      end
    end

    before(:each) do
      EmailVerificationToken.stub(:parse).and_return token
      user.stub(:save) { true }
    end

    it 'should be defined' do
      expect(subject).to respond_to :verify_email
    end

    context 'when token is valid' do
      subject(:response) { get :verify_email, valid_params }

      it 'should redirect to account page if no redirect specified in link' do
        expect(subject).to redirect_to my_account_url
      end

      it 'should redirect to url existing on verification link' do
        valid_params.merge!(redirect: 'google.com')
        expect(subject).to redirect_to 'google.com'
      end

      it 'should save the user' do
        expect(user).to receive(:save)
        subject
      end

      context 'and the user can\'t be saved' do
        before { user.stub(:save).and_return false }
        it_should_behave_like 'something went wrong'
      end

      it 'should publish the user\'s reviews' do
        expect(user).to receive(:publish_reviews!)
        subject
      end

      it 'should verify the user\'s email' do
        expect{ subject }.to change{ user.email_verified? }
          .from(false).to(true)
      end

      it 'should verify the user account (no longer provisional)' do
        expect{ subject }.to change{ user.provisional? }.from(true).to(false)
      end
    end

    context 'with invalid token' do 
      before { EmailVerificationToken.stub(:parse).and_raise 'parse error' }
      subject(:response) { get :verify_email, id: nil, time: nil }

      it_should_behave_like 'something went wrong'
    end

    context 'with expired token' do
      before(:each) do
        EmailVerificationToken.stub(:parse).and_return expired_token
      end
      subject(:response) { get :verify_email, id: nil, time: nil }

      it_should_behave_like 'something went wrong'
    end

    context 'when token\'s encoded user doesn\'t actually exist' do
      before(:each) do
        EmailVerificationToken.stub(:parse).and_return token
        token.stub(:user).and_return nil
      end
      subject(:response) { get :verify_email, id: nil, time: nil }

      it_should_behave_like 'something went wrong'
    end
    
  end

end
