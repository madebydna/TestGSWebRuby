require 'spec_helper'

describe UserValidationConcerns do

  before(:all) do
    class FakeController < ApplicationController
      include UserValidationConcerns
    end
  end

  after(:all) do
    Object.send :remove_const, :FakeController
  end

  before do
    clean_models User
  end

  after do
    clean_models User
  end

  let(:controller) { FakeController.new }

  error_messages_hash =
    {
      'nonexistent_join' => 'No user.',
      'account_without_password' => 'No password error message',
      'provisional_resend_email' => 'provisional resend error message',
      'de_activated' => I18n.t('forms.errors.email.de_activated').html_safe
    }

  describe '#validate_user' do
    context 'with valid email and registered user' do
      let(:user) { FactoryGirl.build(:verified_user) }
      before do
        allow(user).to receive(:has_password?).and_return(true)
        allow(controller).to receive(:email_param_error).and_return(nil)
        allow(controller).to receive(:user_from_email_param).and_return(user)
        allow(user).to receive(:user_profile).and_return(profile)
      end

      context 'when user has disabled profile' do
        let(:profile) { FactoryGirl.build(:inactive_user_profile) }

        it "should use the \'#{I18n.t('forms.errors.email.de_activated')}\' error message" do
          allow(controller).to receive(:default_error_messages).and_return(error_messages_hash)
          expect(controller.validate_user).to eq([user, I18n.t('forms.errors.email.de_activated')])
        end
      end

      context 'when user has no profile' do
        let(:profile) { nil }

        it "should use the return the user and no error" do
          allow(controller).to receive(:default_error_messages).and_return(error_messages_hash)
          expect(controller.validate_user).to eq([user, nil])
        end
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
      allow(controller).to receive(:default_error_messages).and_return(error_messages_hash)


      expect(controller.validate_user).to eq([nil, 'No user.'])
    end

    it 'should not validate if the user is provisional.' do
      user = FactoryGirl.create(:new_user)
      allow(controller).to receive(:params).and_return({email: user.email})
      allow(User).to receive(:find_by_email).and_return(user)
      allow(controller).to receive(:default_error_messages).with(user).and_return(error_messages_hash)

      expect(controller.validate_user).to eq([user, 'provisional resend error message'])
    end

    it 'should not validate if the user has no password.' do
      user = FactoryGirl.build(:email_only, password: nil)
      allow(controller).to receive(:params).and_return({email: user.email})
      allow(User).to receive(:find_by_email).and_return(user)
      allow(controller).to receive(:default_error_messages).with(user).and_return(error_messages_hash)

      expect(controller.validate_user).to eq([user, 'No password error message'])
    end

    it 'should validate the user.' do
      user = FactoryGirl.create(:verified_user)
      allow(controller).to receive(:params).and_return({email: user.email})
      allow(User).to receive(:find_by_email).and_return(user)
      allow(controller).to receive(:default_error_messages).with(user).and_return(error_messages_hash)

      expect(controller.validate_user).to eq([user, nil])
    end

  end

  describe '#user_from_email_param' do
    subject { controller.user_from_email_param }
    it 'should ask User class to find a user' do
      allow(controller).to receive(:params).and_return({email: 'something'})
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
        allow(controller).to receive(:params).and_return({email: 'example@greatschools.org'})
      end
      it 'should return nil' do
        expect(subject).to be_nil
      end
    end
    context 'when email is empty' do
      before do
        allow(controller).to receive(:params).and_return({email: nil})
      end
      it "should return \'#{I18n.t('forms.errors.email.blank')}\'" do
        expect(subject).to eq(I18n.t('forms.errors.email.blank'))
      end
    end
    context 'when email is present but invalid' do
      before do
        allow(controller).to receive(:params).and_return({email: 'junk'})
      end
      it "should return \'#{I18n.t('forms.errors.email.format')}\'" do
        expect(subject).to eq(I18n.t('forms.errors.email.format'))
      end
    end
  end



end