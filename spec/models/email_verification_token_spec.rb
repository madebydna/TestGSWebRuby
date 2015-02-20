require 'spec_helper'

describe EmailVerificationToken do

  describe '.initialize' do
    context 'with a user' do
      let(:user) { FactoryGirl.build(:user) }
      subject(:token) { EmailVerificationToken.new(user: user) }

      it 'should set the current time' do
        expect(subject.instance_variable_get :@time).to be_a Time
      end
    end

    context 'with a token' do
      subject(:token) { EmailVerificationToken.new(user_id: 1, token: 'abc') }
      it 'should set a token' do
        expect(subject.instance_variable_get :@token).to be_a String
      end
    end

    context 'with a user_id' do
      subject(:token) { EmailVerificationToken.new(user_id: 1) }

      it 'should set the current time' do
        expect(subject.instance_variable_get :@time).to be_a Time
      end
    end

    context 'with invalid arguments' do
      it 'should throw an error' do
        expect{ subject }.to raise_error
      end
    end
  end

  describe '.parse' do
    before(:each) do
      allow(User).to receive(:find).and_return FactoryGirl.build(:user)
    end

    context 'with valid token' do
      let(:token_string) { 'X' * 24 }

      # REVIEW: blah is valid user id??
      let(:token_with_user_id) { token_string + 'blah' }

      it 'should generate a valid token' do
        allow(User).to receive(:find).and_return FactoryGirl.build(:user)
        allow(EmailVerificationToken).to receive(:time_from_string) { 4.days.ago }
        token = EmailVerificationToken.parse(token_with_user_id, nil)
        allow(token).to receive(:generate).and_return token_with_user_id
        expect(token).to be_valid
      end
    end

    context 'with invalid token' do
      let(:token_string) { 'X' * 21 }
      let(:token_with_user_id) { token_string + '123' }

      it 'should generate a valid token' do
        expect { EmailVerificationToken.parse(token_with_user_id, nil) }
          .to raise_error
      end
    end
  end

  describe '#expired?' do
    it 'should be expired when more than 5 days old' do
      token = EmailVerificationToken.new(user_id: 1)
      token.instance_variable_set(:@time, 5.days.ago - 1.second)
      expect(token).to be_expired
    end

    it 'should not be expired if less than 5 days old' do
      token = EmailVerificationToken.new(user_id: 1)
      token.instance_variable_set(:@time, 5.days.ago + 1.second)
      expect(token).to_not be_expired
    end
  end

  describe '#generate' do
    let(:user) { FactoryGirl.build(:user) }
    let(:token) { token = EmailVerificationToken.new(user: user) }
    subject(:token_string) { token.generate }

    it 'should generate a token' do
      expect(subject).to be_present
    end

    it 'should end with the user\'s id' do
      expect(subject).to match(/#{user.id}$/)
    end
  end
end
