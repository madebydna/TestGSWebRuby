require 'spec_helper'

shared_context 'user registers a new account' do
  let(:email) { 'testing@greatschools.org' }
  
  before(:each) do
    visit join_path
    fill_in 'join-email', with: email
    check 'terms_terms'
    click_button 'Register email'
  end

  after(:each) do
    clean_models User
  end
end

shared_context 'user clicks link in the email verification email' do
  let(:verification_email) { ActionMailer::Base.deliveries.last }
  let(:verification_link) { verification_email.body.match(/href=\"(.+)\"/)[1] }
  let(:user) { User.with_email verification_email.recipient }
  before do
    visit verification_link
  end
end
