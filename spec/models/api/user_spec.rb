# frozen_string_literal: true

require 'spec_helper'

describe Api::User do
  after do
    clean_models Api::User
  end

  it 'prevents multiple users from using the same email address' do
    user1 = create(:api_user, email: 'test@test.com')
    user2 = Api::User.new(email: 'test@test.com')
    expect(user2.valid?).to be_falsey
    expect(user2.errors.messages[:email]).to eq ['has already been taken']
  end
end
