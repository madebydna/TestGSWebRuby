require 'spec_helper'

describe ForgotPasswordController do

  before do
    clean_models User
  end

  after do
    clean_models User
  end

  describe '#validate_user' do
    context 'when user has disabled profile' do
      let(:user) { FactoryGirl.build(:verified_user) }
      let(:inactive_user_profile) { FactoryGirl.build(:inactive_user_profile) }

      before do
        allow(user).to receive(:has_password?).and_return(true)
        allow(controller).to receive(:email_param_error).and_return(nil)
        allow(controller).to receive(:user_from_email_param).and_return(user)
        allow(user).to receive(:user_profile).and_return(inactive_user_profile)
      end

      it "should use the \'#{I18n.t('forms.errors.email.de_activated')}\' error message" do
        expect(controller.validate_user).to eq([user, I18n.t('forms.errors.email.de_activated')])
      end
    end

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

    it 'should validate the user.' do
      user = FactoryGirl.create(:verified_user)
      allow(controller).to receive(:params).and_return({email: user.email})
      allow(User).to receive(:find_by_email).and_return(user)

      expect(controller.validate_user).to eq([user, nil])
    end

  end

  describe '#user_from_email_param' do
    subject { controller.user_from_email_param }
    it 'should ask User class to find a user' do
      foo = User.new
      stub_user_class = double('User').as_null_object
      stub_const('User', stub_user_class)
      expect(stub_user_class).to receive(:find_by_email).and_return(foo)
      expect(controller.user_from_email_param).to eq(foo)
    end
  end

  describe '#email_param_error' do
    subject { controller.email_param_error }
    context 'with valid email' do
      before do
        controller.params[:email] = 'example@greatschools.org'
      end
      it 'should return nil' do
        expect(subject).to be_nil
      end
    end
    context 'when email is empty' do
      before do
        controller.params[:email] = nil
      end
      it "should return \'#{I18n.t('forms.errors.email.blank')}\'" do
        expect(subject).to eq(I18n.t('forms.errors.email.blank'))
      end
    end
    context 'when email is present but invalid' do
      before do
        controller.params[:email] = 'junk'
      end
      it "should return \'#{I18n.t('forms.errors.email.format')}\'" do
        expect(subject).to eq(I18n.t('forms.errors.email.format'))
      end
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

  describe '#login_and_redirect_to_change_password' do

    it 'should allow reset password if the hash is valid.' do
      user = FactoryGirl.create(:verified_user)
      allow(controller).to receive(:params).and_return({id: user.auth_token})

      expect(controller).to receive(:login_from_hash).with(user.auth_token)
      allow(controller).to receive(:logged_in?) { true }
      expect(controller).to receive(:redirect_to).with(manage_account_url(:anchor => 'change-password'))
      controller.send :login_and_redirect_to_change_password
    end

    it 'should not allow reset password if the hash is not valid.' do
      allow(controller).to receive(:params).and_return({id: 'Sometoken'})

      expect(controller).to receive(:redirect_to).with(signin_url)
      controller.send :login_and_redirect_to_change_password
    end

  end

end