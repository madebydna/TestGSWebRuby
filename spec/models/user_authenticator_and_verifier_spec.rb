require 'spec_helper'

describe UserAuthenticatorAndVerifier do
  let(:user) { FactoryGirl.create(:new_user) }
  let(:token_and_time) { EmailVerificationToken.token_and_date(user) }
  let(:token) { token_and_time[0] }
  let(:time) { token_and_time[1] }
  subject { UserAuthenticatorAndVerifier.new(token, time) }

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

  context 'when date is malformed' do
    let(:token_and_time) { EmailVerificationToken.token_and_date(user, 'fubar date') }
    it { is_expected.to_not be_token_valid }
  end

end