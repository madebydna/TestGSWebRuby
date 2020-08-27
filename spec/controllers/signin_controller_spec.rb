require 'spec_helper'
require 'controllers/modules/authentication_concerns_shared'

describe SigninController do

  before { request.host = 'localhost'; request.port = 3000 }
  it { should respond_to :new }

  # it_behaves_like 'controller with authentication'

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
    context 'when logged in' do
      before do
        allow(controller).to receive(:redirect_to) { }
        allow(controller).to receive(:user_profile_or_home) { 'localhost:3000' }
        allow(controller).to receive(:logged_in?) { true }
      end
      context 'and redirect_url exists in params' do
        before do
          controller.params[:redirect] = 'localhost:3000'
        end
        it 'should execute deferred action' do
          expect(controller).to receive(:executed_deferred_action)
          controller.post_registration_confirmation
        end
      end

      context 'and redirect_url does not exist' do
        before do
          controller.params[:redirect] = nil
        end
        it 'should execute deferred action' do
          expect(controller).to receive(:executed_deferred_action)
          controller.post_registration_confirmation
        end
      end
    end
    context 'redirecting' do
      context 'with a valid redirect url' do
        let (:valid_url) { 'http://www.greatschools.org/account/?flash=success' }
        before do
          allow(controller).to receive(:logged_in?) { true }
          controller.params[:redirect] = valid_url
          allow(controller).to receive(:user_profile_or_home) { 'localhost:3000' }
        end
        it 'should redirect to specified url' do
          expect(controller).to receive(:executed_deferred_action)
          expect(controller).to receive(:redirect_to).with(valid_url)
          controller.post_registration_confirmation
        end
      end

      context 'with an invalid redirect url' do
        let (:invalid_url) { 'http://www.greatschools.org.malicious.cn/account/?flash=success' }
        before do
          allow(controller).to receive(:logged_in?) { true }
          controller.params[:redirect] = invalid_url
          allow(controller).to receive(:user_profile_or_home) { 'localhost:3000' }
        end
        it 'should redirect to specified url' do
          expect(controller).to receive(:executed_deferred_action)
          expect(controller).to receive(:redirect_to).with('localhost:3000')
          controller.post_registration_confirmation
        end
      end
    end
  end

  describe '#create' do
    # Getting inconsistent failures on duplicate key violation so I added this
    before { clean_models(:gs_schooldb, User) }

    describe 'authenticate' do
      it 'should call authenticate if post contained password info' do
        expect(controller).to receive(:authenticate).and_return([nil, 'err_msg'])
        get :create, password: 'abc'
      end

      context 'using xhr' do
        it 'when xhr should return an error' do
          expect(controller).to receive(:authenticate).and_return([nil, 'err_msg'])
          xhr :post, :create, password: 'abc'
          expect(response.status).to eq(422)
        end

        context 'successful login' do
          after do
            clean_dbs :gs_schooldb
          end

          it 'should log the user in' do
            user = instance_double(User)
            expect(controller).to receive(:authenticate).and_return([user, nil])
            expect(controller).to receive(:log_user_in).with(user)
            allow(user).to receive(:id).and_return(1)
            xhr :post, :create, password: 'abc'
          end

          it 'should render user data' do
            user = create(:verified_user, password: 'password')
            xhr :post, :create, format: :json, email: user.email, password: 'password'
            expect(response.status).to eq(200)
            json = response.body
            # hash = JSON.parse(response.body)
            # expect(hash).to have_key('user')
          end
        end
      end

      context 'authentication error' do
        before do
          expect(controller).to receive(:authenticate).and_return([nil, 'err_msg'])
          expect(controller).to receive(:flash_error).with('err_msg')
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
          allow(user).to receive(:id).and_return(1)
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
      # Getting inconsistent failures on duplicate key violation so I added this
      before { clean_models(:gs_schooldb, User) }

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
          expect(controller).to receive(:register).and_return([nil, 'err_msg'])
          expect(controller).to receive(:flash_error).with('err_msg')
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
      allow(ReviewEmailVerificationEmail).to receive(:deliver_to_user)
    end
    subject { controller.send(:register) }

    context 'when it successfully registers a user' do
      before do
        expect(controller).to receive(:register_user).and_return([user, nil])
      end

      RSpec.shared_examples 'sends EmailVerificationEmail' do
        it 'should send an EmailVerificationEmail' do
          expect(EmailVerificationEmail).to receive(:deliver_to_user).and_return(true)
          expect(ReviewEmailVerificationEmail).to_not receive(:deliver_to_user)
          subject
        end
      end

      RSpec.shared_examples 'sends ReviewEmailVerificationEmail' do
        it 'should send a ReviewEmailVerificationEmail' do
          expect(EmailVerificationEmail).to_not receive(:deliver_to_user)
          expect(ReviewEmailVerificationEmail).to receive(:deliver_to_user).and_return(true)
          subject
        end
      end

      include_examples 'sends EmailVerificationEmail'

      context 'when a valid school is specified' do
        before do
          school = FactoryBot.create(:school)
          controller.params[:state] = school.state
          controller.params[:school_id] = school.id
        end

        after do
          clean_models(:ca, School)
        end

        include_examples 'sends ReviewEmailVerificationEmail'
      end

      context 'when an inactive school is specified' do
        before do
          school = FactoryBot.create(:inactive_school)
          controller.params[:state] = school.state
          controller.params[:school_id] = school.id.to_s
        end

        after do
          clean_models(:ca, School)
        end

        include_examples 'sends EmailVerificationEmail'
      end

      context 'when a school that does not exist is specified' do
        before do
          controller.params[:state] = 'wy'
          controller.params[:school_id] = '1234'
        end

        include_examples 'sends EmailVerificationEmail'
      end

      context 'when an invalid state is specified' do
        before do
          controller.params[:state] = 'zz'
          controller.params[:school_id] = '1'
        end

        include_examples 'sends EmailVerificationEmail'
      end

      context 'when only a state is specified' do
        before do
          controller.params[:state] = 'ca'
        end

        include_examples 'sends EmailVerificationEmail'
      end

      context 'when only a school id is specified' do
        before do
          controller.params[:school_id] = '1'
        end

        include_examples 'sends EmailVerificationEmail'
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

  describe '#school' do
    subject { controller.send(:school) }
    let(:school) { instance_double(School) }
    let(:state) { nil }
    let(:school_id) { nil }

    before do
      controller.params[:state] = state
      controller.params[:school_id] = school_id
    end

    it 'does nothing with no params' do
      expect(School).to_not receive(:find_by_state_and_id)
      subject
    end

    context 'with both params' do
      let(:state) { 'ny' }
      let(:school_id) { '1' }

      context 'that map to an active school' do
        before do
          expect(School).to receive(:find_by_state_and_id).and_return(school)
          expect(school).to receive(:active?).and_return true
        end

        it { is_expected.to be(school) }
      end

      context 'that map to an inactive school' do
        before do
          expect(School).to receive(:find_by_state_and_id).and_return(school)
          expect(school).to receive(:active?).and_return false
        end

        it { is_expected.to be_nil }
      end

      context 'that do not map to a school' do
        before { expect(School).to receive(:find_by_state_and_id).and_return(nil).once }

        it { is_expected.to be_nil }

        it 'only executes the find once even when called twice' do
          subject
          expect { controller.send(:school) }.to_not raise_error
        end
      end
    end
  end

  describe '#state' do
    subject { controller.send(:state) }
    let(:state) { 'ca' }
    let(:valid) { true }

    before do
      controller.params[:state] = state
      expect(States).to receive(:is_abbreviation?).with(state).and_return(valid)
    end

    context 'when called with a valid state' do
      it { is_expected.to eq(state) }
    end

    context 'when called with an invalid state' do
      let(:valid) { false }

      it { is_expected.to be_nil }
    end
  end

  describe '#school_id' do
    subject { controller.send(:school_id) }
    before { controller.params[:school_id] = school_id }

    context 'with no parameter' do
      let(:school_id) { nil }

      it { is_expected.to be_nil }
    end

    context 'with garbage parameter' do
      let(:school_id) { 'foo' }

      it { is_expected.to eq(0) }
    end

    context 'with integer parameter' do
      let(:school_id) { '15' }

      it { is_expected.to eq(15) }
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

  describe '#verify_email' do
    let(:user) { FactoryBot.build(:user) }
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

    context 'with a + in token' do
      let(:user_authenticator_and_verifier) { instance_double(UserAuthenticatorAndVerifier) }
      let(:id_str) { "d7FImQxLtZVjJY0+E+mwKg==#{user.id}" }
      let(:time) { Time.now.asctime }
      let(:valid_params) {{
          id: id_str,
          date: time
      }}
      subject(:response) { get :verify_email, valid_params }
      before { allow(user_authenticator_and_verifier).to receive(:authenticated?).and_return false }

      it 'should not improperly decode the parameter' do
        expect(UserAuthenticatorAndVerifier).to receive(:new).with(id_str, time).and_return(user_authenticator_and_verifier)
        subject
      end
    end

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

      it 'should redirect to url existing on verification link if valid' do
        valid_params.merge!(redirect: 'http://www.greatschools.org')
        expect(subject).to redirect_to 'http://www.greatschools.org'
      end

      it 'should redirect to account page if redirect specified in link is invalid' do
        valid_params.merge!(redirect: 'http://www.greatschools.org.google.com')
        expect(subject).to redirect_to my_account_url
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

        it 'should redirect to url existing on verification link if valid' do
          valid_params.merge!(redirect: 'https://www.greatschools.org/')
          expect(subject).to redirect_to 'https://www.greatschools.org/'
        end

        it 'should redirect to account page if url existing on verification link is invalid' do
          valid_params.merge!(redirect: 'https://www.greatschools.org.google.com')
          expect(subject).to redirect_to my_account_url
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

    describe '#facebook_auth' do
      it 'renders 422 when required parameters are missing' do
        xhr :post, :facebook_auth
        expect(response.status).to eq(422)
      end

      it 'does something when provided parameters' do
        command = double
        email = 'aroy@greatschools.org'
        signed = '1234'
        expect(FacebookSignedRequestSigninCommand).
            to receive(:new).
                with(signed, email, hash_excluding(:email, :facebook_signed_request)).
                and_return(command)
        expect(command).to receive(:join_or_signin)
        allow(controller).to receive(:params).and_return 'email' => email, 'facebook_signed_request' => signed
        controller.facebook_auth
      end
    end

    describe '#google_auth' do
      before do
        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:google]
      end

      after(:each) do
        clean_dbs :gs_schooldb
      end

      it 'should successfully create a user if none existed' do
        expect { get :google_auth, provider: :google }.to change{ User.count }.by(1)
        expect(response).to redirect_to(manage_account_url)
      end

      it 'should return existing user' do
        User.create(email: OmniAuth.config.mock_auth[:google].info.email, password: "fillerbarn")
        expect { get :google_auth, provider: :google }.to change{ User.count }.by(0)
        expect(response).to redirect_to(manage_account_url)
        expect(subject).not_to receive(:send_verification_email)
      end

      it "should successfully create a session" do
        expect(session[:user_id]).to be_nil
        get :google_auth, provider: :google
        expect(session[:user_id]).not_to be_falsey
        expect(response).to redirect_to(manage_account_url)
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
      let(:user) { FactoryBot.create(:new_user) }
      let(:valid_token) { token.generate }
      let(:valid_time) { token.time_as_string }
      let(:invalid_token) { 'foo' }
      let(:redirect) { '/foo' }

      context 'given a bad redirect url' do
        let(:bad_redirect) { 'http://foo.bar.taz/' }
        before { allow(controller).to receive(:params).and_return(id: CGI.escape(valid_token), date: valid_time, redirect: bad_redirect) }

        it 'should redirect to the account page' do
          expect(controller).to receive(:redirect_to).with(my_account_path)
          controller.send :authenticate_token_and_redirect
        end
      end
      context 'given a valid token' do
        before { allow(controller).to receive(:params).and_return(id: CGI.escape(valid_token), date: valid_time, redirect: redirect) }

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
end
