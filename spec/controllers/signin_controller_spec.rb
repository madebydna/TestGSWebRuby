require 'spec_helper'
require 'concerns/authentication_concerns_spec'

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
          expect(get :create, password: 'abc').to redirect_to(signin_url(only_path: true) + '/')
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
          expect(get :create, email: 'blah@example.com').to redirect_to(signin_url(only_path: true) + '/')
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


end
