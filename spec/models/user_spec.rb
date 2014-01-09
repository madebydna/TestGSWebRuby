require 'spec_helper'

describe User do

  context 'new user with valid password' do
    let!(:user) { FactoryGirl.build(:new_user) }

    before(:each) { user.encrypt_plain_text_password }

    it 'should be able to have subscriptions' do
      association = User.reflect_on_association(:subscriptions)
      expect(association.macro).to eq(:has_many)
    end

    it 'should be provisional after being saved' do
      pending 'pending review and fix this test'
      user.save!
      user.password = 'password'
      expect(user).to be_provisional
    end

    it 'allows valid password to be saved' do
      user.password = 'password'
      expect{user.save!}.to be_true
    end

    it 'throws validation error if password too short' do
      user.password = 'pass'
      user.encrypt_plain_text_password
      expect{user.save!}.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'should have a value for time_added' do
      expect(user.time_added).to_not be_nil
    end

    describe '#new_subscription!' do
      let(:user) { FactoryGirl.build(:user) }
      let(:now) { Time.now }

      it 'sets default state and school id when no school provided' do
        subscription = user.new_subscription(:mystat)
        expect(subscription.state).to eq('CA')
        expect(subscription.school_id).to eq(0)
      end

      it 'defaults expires to 0 when no expiration set' do
        subscription_product = Subscription::SubscriptionProduct.new('mystat', 'My School Stats', nil, true)
        Subscription.stub(:subscription_product).with(:mystat).and_return(subscription_product)
        subscription = user.new_subscription(:mystat)
        expect(subscription.expires).to eq(0)
      end

      it 'should perform expiration date math correctly' do
        subscription_product = Subscription::SubscriptionProduct.new('mystat', 'My School Stats', 1.year, true)

        Subscription.stub(:subscription_product).with(:mystat).and_return(subscription_product)

        subscription = user.new_subscription(:mystat)
        expires = subscription.expires
        expect(expires.year).to eq(now.year + 1)
        expect(expires.month).to eq(now.month)
        expect(expires.day).to eq(now.day)
      end

      it 'raises an exception if it can\'t find subscription_product' do
        expect{ user.new_subscription 'bogus' }.to raise_error
      end
    end

    describe '#password_is?' do

      it 'checks for valid passwords' do
        user.password = 'password'
        user.encrypt_plain_text_password
        expect(user.password_is? 'password').to be_true
        expect(user.password_is? 'pass').to be_false
      end

      it 'does not allow nil or blank passwords' do
        expect(user.password_is? '').to be_false
        expect(user.password_is? nil).to be_false
        expect{user.save!}.to raise_error(ActiveRecord::RecordInvalid)
      end

      # required use of string#rindex in code
      it 'should match the right password when password is "provisional:" ' do
        user.password = 'provisional:'
        user.encrypt_plain_text_password
        expect(user.password_is? 'provisional:').to be_true
      end
    end

    describe '#validate_email_verification_token' do
      before(:each) do
        @token, @time = user.email_verification_token
      end

      it 'returns false when given nils and blanks' do
        expect(User.validate_email_verification_token nil, nil).to be_false
        expect(User.validate_email_verification_token '', nil).to be_false
        expect(User.validate_email_verification_token nil, '').to be_false
        expect(User.validate_email_verification_token '', '').to be_false
      end

      it 'returns false for malformed token' do
        expect(User.validate_email_verification_token 'not_a_valid_token', @time.to_s).to be_false
        longer_token = (1..24).to_a.join
        expect(User.validate_email_verification_token longer_token, @time.to_s).to be_false
      end

      describe 'with a valid token' do

        it 'returns a user when it gets a valid token and date' do
          User.stub(:find).and_return(user)

          verified_user = User.validate_email_verification_token @token, @time

          expect(verified_user).to eq(user)
          expect(user).to be_email_verified
        end

        it 'returns false if date is expired' do
          expired_date = Time.now - EmailVerificationToken::EMAIL_TOKEN_EXPIRATION
          expect(User.validate_email_verification_token @token, expired_date).to be_false
        end

        it 'returns false if date is in the future' do
          expired_date = Time.now + 1.day
          expect(User.validate_email_verification_token @token, expired_date).to be_false
        end

        it 'returns false if date is malformed' do
          expect(User.validate_email_verification_token @token, 'not_a_valid_date').to be_false
        end
      end
    end

  end


end