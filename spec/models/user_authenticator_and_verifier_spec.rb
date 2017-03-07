require 'spec_helper'

describe UserAuthenticatorAndVerifier do
  let(:user) { FactoryGirl.create(:new_user) }
  let(:token_and_time) { EmailVerificationToken.token_and_date(user) }
  let(:token) { token_and_time[0] }
  let(:time) { token_and_time[1] }
  subject { UserAuthenticatorAndVerifier.new(token, time) }

  after  { clean_dbs :gs_schooldb }

  context 'when given nils and blanks' do
    [
        [nil, nil],
        ['', nil],
        [nil, ''],
        ['', '']
    ].each do |token, time|
      subject { UserAuthenticatorAndVerifier.new(token, time) }
      it { is_expected.to_not be_token_valid }
    end
  end

  context 'with a malformed token' do
    subject { UserAuthenticatorAndVerifier.new('invalid_token', time) }
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

  context 'when date is 50 days ago' do
    let(:token_and_time) { EmailVerificationToken.token_and_date(user, 50.days.ago) }
    it { is_expected.to_not be_token_valid }
  end

  context 'when date is malformed' do
    let(:token_and_time) { EmailVerificationToken.token_and_date(user, 'fubar date') }
    it { is_expected.to_not be_token_valid }
  end

  context 'Attempt to hack token by swapping user id for another user' do
    let(:another_user) { FactoryGirl.create(:new_user) }
    let(:invalid_token) { token.sub(/==\d+$/, "==#{another_user.id.to_s}") }
    let(:hacked_subject) { UserAuthenticatorAndVerifier.new(invalid_token, time) }

    it 'is not authenticated' do
      expect(subject.authenticated?).to be_truthy
      expect(hacked_subject.authenticated?).to be_falsey
    end
  end

  context 'Attempt to hack token by swapping user id for a nonexisting user' do
    let(:invalid_token) { token.sub(/==\d+$/, '==99999998') }
    let(:hacked_subject) { UserAuthenticatorAndVerifier.new(invalid_token, time) }

    it 'is not authenticated' do
      expect(subject.authenticated?).to be_truthy
      expect(hacked_subject.authenticated?).to be_falsey
    end
  end
end