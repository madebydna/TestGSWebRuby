# frozen_string_literal: true

require 'spec_helper'

describe Api::User do
  let(:user) { create(:api_user, first_name: 'Andy', last_name: 'Luo', city: 'Oakland', state: 'ca') }

  after do
    clean_models Api::User
  end

  it 'prevents multiple users from using the same email address' do
    user1 = create(:api_user, email: 'test@test.com')
    user2 = Api::User.new(email: 'test@test.com')
    expect(user2.valid?).to be_falsey
    expect(user2.errors.messages[:email]).to eq ['has already been taken']
  end

  it '#full_name' do
    expect(user.full_name).to eq('Andy Luo')
  end

  it '#locality' do
    expect(user.locality).to eq('Oakland, CA')
  end
end
