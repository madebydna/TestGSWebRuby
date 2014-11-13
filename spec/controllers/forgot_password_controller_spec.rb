require 'spec_helper'

describe ForgotPasswordController do

  after do
    clean_models User
  end

  describe '#validate_user' do

    it 'should not validate with invalid email.' do
      allow(controller).to receive(:params).and_return({email: 'invalid email'})

      expect(controller.validate_user).to eq([nil, "Please enter a valid email address."])
    end

    it 'should not validate if email is empty.' do
      allow(controller).to receive(:params).and_return({})

      expect(controller.validate_user).to eq([nil, "Please enter an email address."])
    end

    it 'should not validate if we are not able to retrieve a user.' do
      allow(controller).to receive(:params).and_return({email: 'someone@somedomain.com'})
      allow(User).to receive(:find_by_email).and_return(nil)

      expect(controller.validate_user).to eq([nil, "There is no account associated with that email address. Would you like to <a href=#{join_url}>join GreatSchools</a>?"])
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



end