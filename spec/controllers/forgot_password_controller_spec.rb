require 'spec_helper'

describe ForgotPasswordController do

  after do
    clean_models User
  end

  describe '#validate_user' do

    it 'should not validate with invalid email.' do
      allow(controller).to receive(:params).and_return({email: 'invalid email'})
      allow(controller).to receive(:t).with('forms.errors.email.format').and_return('Invalid email.')

      expect(controller.validate_user).to eq([nil,'Invalid email.' ])
    end

    it 'should not validate if email is empty.' do
      allow(controller).to receive(:params).and_return({})
      allow(controller).to receive(:t).with('forms.errors.email.blank').and_return('Empty email.')

      expect(controller.validate_user).to eq([nil, 'Empty email.'])
    end

    it 'should not validate if we are not able to retrieve a user.' do
      allow(controller).to receive(:params).and_return({email: 'someone@somedomain.com'})
      allow(User).to receive(:find_by_email).and_return(nil)
      allow(controller).to receive(:t).with('forms.errors.email.nonexistent_join', anything).and_return('No user.')


      expect(controller.validate_user).to eq([nil, 'No user.'])
    end

    it 'should not validate if the user is provisional.' do
      user = FactoryGirl.create(:new_user)
      allow(controller).to receive(:params).and_return({email: user.email})
      allow(User).to receive(:find_by_email).and_return(user)

      allow(controller).to receive(:t).with('forms.errors.email.provisional_resend_email', anything).and_return('provisional resend error message')
      expect(controller.validate_user).to eq([user, 'provisional resend error message'])
    end

    it 'should not validate if the user has no password.' do
      user = FactoryGirl.build(:email_only, password: nil)
      allow(controller).to receive(:params).and_return({email: user.email})
      allow(User).to receive(:find_by_email).and_return(user)

      allow(controller).to receive(:t).with('forms.errors.email.account_without_password', anything).and_return('No password error message')
      expect(controller.validate_user).to eq([user, 'No password error message'])
    end

  end

  describe '#send_reset_password_email' do

    it 'should flash error and redirect if there are validation errors.' do
      error_message = 'some error'
      allow(controller).to receive(:validate_user).and_return([nil,error_message])

      expect(controller).to receive(:redirect_to).with forgot_password_url
      expect(controller).to receive(:flash_error).with error_message
      controller.send :send_reset_password_email
    end

    it 'should redirect if there are no validation errors and no user.' do
      allow(controller).to receive(:validate_user).and_return([nil,''])

      expect(controller).to receive(:redirect_to).with signin_url
      controller.send :send_reset_password_email
    end

    it 'should send email and redirect if there are no validation errors and a valid forgetful user.' do
      user = FactoryGirl.build(:new_user)
      allow(controller).to receive(:validate_user).and_return([user,''])

      expect(ResetPasswordEmail).to receive(:deliver_to_user).with user,reset_password_url
      allow(controller).to receive(:t).with('actions.forgot_password.email_sent', anything).and_return('Email sent')
      expect(controller).to receive(:flash_notice).with 'Email sent'
      expect(controller).to receive(:redirect_to).with signin_url
      controller.send :send_reset_password_email
    end

  end

  describe '#allow_reset_password' do

    it 'should allow reset password if the hash is valid.' do
      user = FactoryGirl.create(:verified_user)
      allow(controller).to receive(:params).and_return({id: user.auth_token})

      expect(controller).to receive(:redirect_to).with(manage_account_url(:anchor => 'change-password'))
      controller.send :allow_reset_password
    end

    it 'should not allow reset password if the hash is not valid.' do
      allow(controller).to receive(:params).and_return({id: 'Sometoken'})

      expect(controller).to receive(:redirect_to).with(signin_url)
      controller.send :allow_reset_password
    end

  end

end