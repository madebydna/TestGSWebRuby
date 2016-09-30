require 'spec_helper'
require 'controllers/modules/authentication_concerns_shared'

describe SigninController do

  before { request.host = 'localhost'; request.port = 3000 }
  it { should respond_to :new }

  it_behaves_like 'controller with authentication'

  describe '#store_location' do
    it 'should store_location when #new method called on controller' do
      expect(controller).to receive(:has_stored_location?).and_return(false)
      expect(controller).to receive(:store_location)
      get :new
    end
  end

  describe '#new_join' do
    it 'sets meta tags' do
      expect(controller).to receive(:set_meta_tags)
      get :new
    end
  end

  describe '#post_registration_confirmation' do
    before do
      allow(controller).to receive(:redirect_to) { }
      allow(controller).to receive(:user_profile_or_home) { 'localhost:3000' }
    end
    context 'when logged in' do
      before do
        allow(controller).to receive(:logged_in?) { true }
      end
      context 'and redirect_url exists in params' do
        before do
          controller.params[:redirect] = 'localhost:3000'
        end
        it 'should execute defered action' do
          expect(controller).to receive(:executed_deferred_action)
          controller.post_registration_confirmation
        end
      end

      context 'and redirect_url does not exist' do
        before do
          controller.params[:redirect] = nil
        end
        it 'should execute defered action' do
          expect(controller).to receive(:executed_deferred_action)
          controller.post_registration_confirmation
        end
      end
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
        let(:user) { instance_double(User) }
        subject(:response) { get :create, {password: 'abc'} }

        before do
          expect(controller).to receive(:authenticate).and_return([user, nil])
        end

        it 'should log the user in' do
          expect(controller).to receive(:log_user_in).with(user)
          get :create, password: 'abc'
        end

        it 'should redirect to home if no redirect specified' do
          allow(controller).to receive(:should_attempt_login).and_return(true)
          allow(controller).to receive(:log_user_in).with(user)
          allow(controller).to receive(:home_url).and_return('/') # To avoid issue where rspec generates join_url incorrectly (with trailing slash)
          expect(subject).to redirect_to '/'
        end

        it 'should redirect to overview page last visited' do
          allow(controller).to receive(:should_attempt_login).and_return(true)
          allow(controller).to receive(:log_user_in).with(user)
          allow(controller).to receive(:overview_page_for_last_school).and_return('/profile-url')
          expect(subject).to redirect_to '/profile-url'
        end

        it 'should redirect  if the redirect cookie is set' do
          allow(controller).to receive(:should_attempt_login).and_return(true)
          allow(controller).to receive(:log_user_in).with(user)
          cookies[:redirect_uri] = '/city-hub/'
          expect(subject).to redirect_to '/city-hub/'
        end

        it 'should redirect to redirect cookie even if overview page last visited cookie is set' do
          allow(controller).to receive(:should_attempt_login).and_return(true)
          allow(controller).to receive(:log_user_in).with(user)
          allow(controller).to receive(:overview_page_for_last_school).and_return('/profile-url')
          cookies[:redirect_uri] = '/city-hub/'
          expect(subject).to redirect_to '/city-hub/'
        end
      end
    end

    describe 'register' do

      after(:all) do
        clean_dbs :gs_schooldb
      end

      it 'should register new user if no password provided' do
        expect {
          get :create, email: 'blah@example.com'
        }.to change(User, :count).by(1)
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
        let(:user) { instance_double(User).as_null_object }
        subject(:response) { get :create, {email: 'blah@example.com'} }
        before do
          allow(user).to receive(:provisional?).and_return(false)
          expect(controller).to receive(:register).and_return([user, nil])
          allow(controller).to receive(:log_user_in)
        end

        it 'should tell the user what to do next' do
          expect(controller).to receive(:flash_notice)
          get :create, email: 'blah@example.com'
        end

        it 'should log in the user' do
          expect(controller).to receive(:log_user_in).with(user) {}
          post :create, email: 'blah@example.com'
        end

        it 'should redirect to join if no redirect specified' do
          expect(subject).to redirect_to join_url
        end

        it 'should redirect to overview page last visited' do
          allow(controller).to receive(:overview_page_for_last_school).and_return('/profile-url')
          expect(subject).to redirect_to '/profile-url'
        end

        it 'should redirect  if the redirect cookie is set' do
          cookies[:redirect_uri] = '/city-hub/'
          expect(subject).to redirect_to '/city-hub/'
        end

        it 'should redirect to redirect cookie even if overview page last visited cookie is set' do
          allow(controller).to receive(:overview_page_for_last_school).and_return('/profile-url')
          cookies[:redirect_uri] = '/city-hub/'
          expect(subject).to redirect_to '/city-hub/'
        end

        it 'should not decode square brackets if redirect_uri contains encoded square brackets' do
          cookies[:redirect_uri] = '/delaware/dover/schools?st%5B%5D=public&st%5B%5D=charter'
          expect(subject).to redirect_to '/delaware/dover/schools?st%5B%5D=public&st%5B%5D=charter'
          expect(subject.request.url).not_to include '['
          expect(subject.request.url).not_to include ']'
        end
      end
    end

  end

  describe '#register' do
    let(:user) { instance_double(User, user_profile: double('UserProfile').as_null_object) }
    before do
      controller.params[:email] = 'test@greatschools.org'
      allow(controller).to receive(:email_verification_url).and_return(nil)
      allow(EmailVerificationEmail).to receive(:deliver_to_user)
    end
    subject { controller.send(:register) }

    context 'when it successfully registers a user' do
      before do
        expect(controller).to receive(:register_user).and_return([user, nil])
      end
      it 'should send an EmailVerificationEmail to the user' do
        expect(EmailVerificationEmail).to receive(:deliver_to_user).and_return(true)
        subject
      end

      context 'and user has no profile' do
        before do
          allow(user).to receive(:user_profile).and_return(nil)
        end
        it 'method should finish executing without error' do
          expect { subject }.to_not raise_error
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
    let(:user) { instance_double(User) }
    before do
      allow(controller).to receive(:params).and_return({ email: 'blah@example.com' })
      allow(user).to receive(:has_password?).and_return(true)
      allow(user).to receive(:password_is?).and_return(true)
    end

    it 'should authenticate even if the email is provisional' do
      expect(User).to receive(:with_email).and_return(user)
      expect(controller.send :authenticate).to eq([ user, nil ])
    end

    it 'should return an existing user and error message to set password if the account has no password' do
      expect(User).to receive(:with_email).and_return(user)
      expect(user).to receive(:has_password?).and_return(false)
      expect(I18n).to receive(:t).with('forms.errors.email.account_without_password', anything).and_return('account without password error message')
      expect(controller.send :authenticate).to eq([ user, 'account without password error message' ])
    end

    it 'should return an existing user and error message if the passwords do not match' do
      expect(User).to receive(:with_email).and_return(user)
      expect(user).to receive(:password_is?).and_return(false)
      expect(controller.send :authenticate).to eq([ user, "The email or password you entered is invalid. Please try again or <a href=\"http://localhost/join/\">create an account</a>." ])
    end

    it 'should return an existing user if one exists and it matches given password and no error message.' do
      expect(User).to receive(:with_email).and_return(user)
      expect(controller.send :authenticate).to eq([ user, nil ])
    end
  end

  describe '#facebook_connect' do
    it 'redirects to a facebook uri' do
      get :facebook_connect
      redirect_uri = 'https://graph.facebook.com/oauth/authorize' +
                     '?client_id=178930405559082&' +
                     'redirect_uri=http%3A%2F%2Flocalhost%2Fgsr%2Fsession%2Ffacebook_callback%2F&scope=email'
      expect(response).to redirect_to(redirect_uri)
    end
  end

  describe '#facebook_callback' do
    def stub_fb_login_fail
      allow(controller).to receive(:facebook_login) { [nil, double('error')] }
    end

    def stub_fb_login_success
      user = double('user', id: 1, auth_token: 'foo', provisional_or_approved_osp_user?: 'foo')
      allow(user).to receive(:provisional?).and_return(false)
      allow(controller).to receive(:current_user) { user }
      allow(controller).to receive(:facebook_login) { [user, nil] }
    end

    context 'without an access code' do
      before(:each) do
        allow(FacebookAccess).to receive(:facebook_code_to_access_token) { nil } # make it so the method returns the code or nil
      end

      it 'logs and flashes an error' do
        error_message = 'Could not log in with Facebook.'
        expect(Rails.logger).to receive(:debug).at_least(1).times
        get :facebook_callback
        expect(flash[:error][0]).to eq(error_message)
      end

      it 'redirects to the signin url' do
        get :facebook_callback
        expect(response).to redirect_to(signin_path)
      end
    end

    context 'with an access code' do
      before(:each) do
        allow(FacebookAccess).to receive(:facebook_code_to_access_token) { 'foobar' }
      end

      it 'executes deferred actions' do
        stub_fb_login_fail
        allow(controller).to receive(:executed_deferred_action).and_return(nil)
        get :facebook_callback, code: 'fb-code'
      end

      context 'logging user into facebook' do
        it 'logs in the user' do
          allow(controller).to receive(:facebook_login) { [double('user'), nil] }
          allow(controller).to receive(:log_user_in)
          get :facebook_callback, code: 'fb-code'
        end
      end

      context 'error from loggin into facebook' do
        it 'does not log in the user' do
          stub_fb_login_fail
          expect(controller).to_not receive(:log_user_in)
          get :facebook_callback, code: 'fb-code'
        end
      end

      describe 'redirecting' do
        context 'when deferred actions redirect' do
          it 'delegates the redirect to the deferred action' do
            stub_fb_login_fail
            allow(controller).to receive(:executed_deferred_action) do
              controller.redirect_to city_path('michigan', 'detroit')
            end

            get :facebook_callback, code: 'fb-code'
            expect(response).to redirect_to(city_path('michigan', 'detroit'))
          end
        end

        context 'without deferred action redirects' do
          context 'after visiting a school reviews page' do
            it 'redirects to the overview path for that school' do
              stub_fb_login_fail
              allow(controller).to receive(:overview_page_for_last_school) { '/overview-url-double' }
              get :facebook_callback, code: 'fb-code'
              expect(response).to redirect_to('/overview-url-double')
            end
          end

          context 'with a redirect_uri cookie set' do
            it 'prefers school overview' do
              stub_fb_login_fail
              cookies[:redirect_uri] = '/cookie-redirect-path'
              allow(controller).to receive(:overview_page_for_last_school) { '/overview-url-double' } # prefer cookie
              get :facebook_callback, code: 'fb-code'
              expect(response).to redirect_to('/overview-url-double')
            end
            it 'should not decode square brackets if redirect_uri contains encoded square brackets' do
              stub_fb_login_fail
              cookies[:redirect_uri] = '/delaware/dover/schools?st%5B%5D=public&st%5B%5D=charter'
              allow(controller).to receive(:overview_page_for_last_school) { nil }
              get :facebook_callback, code: 'fb-code'
              expect(subject).to redirect_to '/delaware/dover/schools?st%5B%5D=public&st%5B%5D=charter'
              expect(subject.request.url).not_to include '['
              expect(subject.request.url).not_to include ']'
            end
          end

          context 'logged in' do
            it 'redirects to the account page' do
              stub_fb_login_success
              allow(controller).to receive(:overview_page_for_last_school) { nil }
              get :facebook_callback, code: 'fb-code'
              expect(response).to redirect_to('/account/')
            end
          end

          context 'not logged in' do
            it 'redirects to the home page' do
              stub_fb_login_fail
              allow(controller).to receive(:overview_page_for_last_school) { nil }
              get :facebook_callback, code: 'fb-code'
              expect(response).to redirect_to(home_url)
            end
          end
        end
      end
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
      allow(EmailVerificationToken).to receive(:parse).and_return token
      allow(user).to receive(:save) { true }
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

      context 'and the user is not valid' do
        before { allow(user).to receive(:valid?).and_return false }
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

      it 'should sign the user in' do
        expect(controller).to receive(:log_user_in).with user
        subject
      end

      it 'should set a Google Analytics event' do
        expect(controller).to receive(:insert_into_ga_event_cookie).with 'registration', 'verified email', 'regular', nil, true
        subject
      end

      context 'and the user is already verified' do
        before do
          user.verify!
        end

        it 'should not set a Google Analytics event' do
          expect(controller).to_not receive(:insert_into_ga_event_cookie).with 'registration', 'verified email', 'regular', nil, true
          subject
        end

        it 'should still publish the user\'s reviews' do
          expect(user).to receive(:publish_reviews!)
          subject
        end

        it 'should redirect to account page if no redirect specified in link' do
          expect(subject).to redirect_to my_account_url
        end

        it 'should redirect to url existing on verification link' do
          valid_params.merge!(redirect: 'google.com')
          expect(subject).to redirect_to 'google.com'
        end
      end
    end

    context 'with invalid token' do
      before { allow(EmailVerificationToken).to receive(:parse).and_raise 'parse error' }
      subject(:response) { get :verify_email, id: nil, time: nil }

      it_should_behave_like 'something went wrong'
    end

    context 'with expired token' do
      before(:each) do
        allow(EmailVerificationToken).to receive(:parse).and_return expired_token
      end
      subject(:response) { get :verify_email, id: nil, time: nil }

      it_should_behave_like 'something went wrong'
    end

    context 'when token\'s encoded user doesn\'t actually exist' do
      before(:each) do
        allow(EmailVerificationToken).to receive(:parse).and_return token
        allow(token).to receive(:user).and_return nil
      end
      subject(:response) { get :verify_email, id: nil, time: nil }

      it_should_behave_like 'something went wrong'
    end

  end

  describe SigninController::FacebookSignedRequestSigninCommand do
    let(:user) { double('user') }
    let(:params) do
      {
          'email' => 'example@greatschools.org',
          'facebook_signed_request' => 123
      }
    end
    subject(:command) do
      command = SigninController::FacebookSignedRequestSigninCommand.new_from_request_params(params)
    end

    context 'when signed request is not valid' do
      before do
        allow(MiniFB).to receive(:verify_signed_request).
                              with(ENV_GLOBAL['facebook_app_secret'], params['facebook_signed_request']).
                              and_return(false)
      end
      it 'raises an exception' do
        expect { SigninController::FacebookSignedRequestSigninCommand.new_from_request_params(params) }.to raise_error
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

  describe '#authenticate_token_and_redirect' do
    before do
      allow(controller).to receive(:redirect_to)
    end

    after { clean_dbs(:gs_schooldb) }

    context 'given an unverified user' do
      let(:token) { EmailVerificationToken.new(user: user) }
      let(:expired_token) {
        EmailVerificationToken.new(user: user, time: 1000.years.ago)
      }
      let(:user) { FactoryGirl.create(:new_user) }
      let(:valid_token) { token.generate }
      let(:valid_time) { token.time_as_string }
      let(:invalid_token) { 'foo' }
      let(:redirect) { '/foo' }

      context 'given a valid token' do
        before { allow(controller).to receive(:params).and_return(id: valid_token, date: valid_time, redirect: redirect) }

        it 'should verify the user\'s email' do
          allow(controller).to receive(:redirect_to).with(password_url)
          controller.send :authenticate_token_and_redirect
          user.reload
          expect(user).to_not be_provisional
        end

        it 'should redirect to the requested page' do
          expect(controller).to receive(:redirect_to).with(redirect)
          controller.send :authenticate_token_and_redirect
        end

        it 'should log the user in' do
          controller.send :authenticate_token_and_redirect
          expect(controller.send(:logged_in?)).to be_truthy
        end
      end

      context 'given an invalid token' do
        before { allow(controller).to receive(:params).and_return(id: invalid_token, date: valid_time, redirect: redirect) }

        it 'should not verify the user\'s email' do
          controller.send :authenticate_token_and_redirect
          user.reload
          expect(user).to be_provisional
        end

        it 'should redirect to home page' do
          expect(controller).to receive(:redirect_to).with(home_url)
          controller.send :authenticate_token_and_redirect
        end

        it 'should not log the user in' do
          controller.send :authenticate_token_and_redirect
          expect(controller.send(:logged_in?)).to be_falsey
        end

        it 'should flash an error message' do
          expect(controller).to receive(:flash_error).with(I18n.t('controllers.forgot_password_controller.token_invalid'))
          controller.send :authenticate_token_and_redirect
        end
      end
    end
  end

  describe SigninController::UserAuthenticatorAndVerifier do
    let(:user) { FactoryGirl.create(:new_user) }
    let(:token_and_time) { EmailVerificationToken.token_and_date(user) }
    let(:token) { token_and_time[0] }
    let(:time) { token_and_time[1] }
    subject { SigninController::UserAuthenticatorAndVerifier.new(token, time) }

    context 'when given nils and blanks' do
      [
        [nil, nil],
        ['', nil],
        [nil, ''],
        ['', '']
      ].each do |token, time|
        subject { SigninController::UserAuthenticatorAndVerifier.new(token, time) }
        it { is_expected.to_not be_token_valid }
      end
    end

    context 'with a malformed token' do
      subject { SigninController::UserAuthenticatorAndVerifier.new('invalid_token', time) }
      it { is_expected.to_not be_token_valid }
    end

    context 'when date is in the future' do
      let(:token_and_time) { EmailVerificationToken.token_and_date(user, 10.days.from_now) }
      it { is_expected.to_not be_token_valid }
    end

    context 'when date is a second ago' do
      let(:token_and_time) { EmailVerificationToken.token_and_date(user, 1.second.ago) }
      it { is_expected.to be_token_valid }
    end

    context 'when date is yesterday' do
      let(:token_and_time) { EmailVerificationToken.token_and_date(user, 1.day.ago) }
      it { is_expected.to be_token_valid }
    end

    context 'when date is malformed' do
      let(:token_and_time) { EmailVerificationToken.token_and_date(user, 'fubar date') }
      it { is_expected.to_not be_token_valid }
    end

  end
end
