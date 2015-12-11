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

      expect(ResetPasswordEmail).to receive(:deliver_to_user).with user, create_reset_password_url(user)
      allow(controller).to receive(:t).with('actions.forgot_password.email_sent', anything).and_return('Email sent')
      expect(controller).to receive(:flash_notice).with 'Email sent'
      expect(controller).to receive(:redirect_to).with signin_url
      controller.send :send_reset_password_email
    end

  end

end
