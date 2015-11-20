require 'spec_helper'

describe ForgotPasswordController do

  before do
    clean_models User
  end

  after do
    clean_models User
  end

  describe '#send_reset_password_email' do

    it 'should flash error and redirect if there are validation errors.' do
      error_message = 'some error'
      allow(controller).to receive(:validate_user_can_reset_password).and_return([nil,error_message])

      expect(controller).to receive(:redirect_to).with forgot_password_url
      expect(controller).to receive(:flash_error).with error_message
      controller.send :send_reset_password_email
    end

    it 'should redirect if there are no validation errors and no user.' do
      allow(controller).to receive(:validate_user_can_reset_password).and_return([nil,''])

      expect(controller).to receive(:redirect_to).with signin_url
      controller.send :send_reset_password_email
    end

    it 'should send email and redirect if there are no validation errors and a valid forgetful user.' do
      user = FactoryGirl.build(:new_user)
      allow(controller).to receive(:validate_user_can_reset_password).and_return([user,''])

      expect(ResetPasswordEmail).to receive(:deliver_to_user).with user,reset_password_url
      allow(controller).to receive(:t).with('actions.forgot_password.email_sent', anything).and_return('Email sent')
      expect(controller).to receive(:flash_notice).with 'Email sent'
      expect(controller).to receive(:redirect_to).with signin_url
      controller.send :send_reset_password_email
    end

  end

  describe '#login_and_redirect_to_change_password' do
    before do
      allow(controller).to receive(:redirect_to)
    end

    context 'given an unverified user' do
      let(:user) { FactoryGirl.create(:new_user) }
      let(:valid_token) { user.auth_token }
      let(:invalid_token) { 'foo' }

      context 'given a valid token' do
        before { allow(controller).to receive(:params).and_return(id: valid_token) }

        it 'should verify the user\'s email' do
          allow(controller).to receive(:redirect_to).with(reset_password_page_url)
          controller.send :login_and_redirect_to_change_password
          user.reload
          expect(user).to_not be_provisional
        end

        it 'should redirect to the reset password page' do
          expect(controller).to receive(:redirect_to).with(reset_password_page_url)
          controller.send :login_and_redirect_to_change_password
        end

        it 'should log the user in' do
          expect(controller).to receive(:login_from_hash).with(user.auth_token).and_call_original
          controller.send :login_and_redirect_to_change_password
          expect(controller).to be_logged_in
        end
      end

      context 'given an invalid token' do
        before { allow(controller).to receive(:params).and_return(id: invalid_token) }

        it 'should not verify the user\'s email' do
          controller.send :login_and_redirect_to_change_password
          user.reload
          expect(user).to be_provisional
        end

        it 'should redirect to home page' do
          expect(controller).to receive(:redirect_to).with(home_url)
          controller.send :login_and_redirect_to_change_password
        end

        it 'should not log the user in' do
          controller.send :login_and_redirect_to_change_password
          expect(controller).to_not be_logged_in
        end

        it 'should flash an error message' do
          expect(controller).to receive(:flash_error).with(I18n.t('controllers.forgot_password_controller.token_invalid'))
          controller.send :login_and_redirect_to_change_password
        end
      end
    end
  end

  describe '#login_from_hash' do
    it 'should verify the user\'s email' do
      user = FactoryGirl.build(:new_user)
      expect(User).to receive(:find).and_return(user)
      expect(user).to receive(:verify_email!)
      controller.send(:login_from_hash, user.auth_token)
    end
  end

end