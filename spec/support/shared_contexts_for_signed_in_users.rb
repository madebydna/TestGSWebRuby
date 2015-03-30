require 'spec_helper'

def log_in_user(user)
  host = Capybara.app_host ? URI(Capybara.app_host).host : '127.0.0.1'

  page.driver.browser.set_cookie("auth_token=#{user.auth_token}; domain=#{host}")
  page.driver.browser.set_cookie("MEMID=#{user.id}; domain=#{host}")
  page.driver.browser.set_cookie("community_www=#{user.auth_token.gsub('=', '~')}; domain=#{host}")
end

shared_context 'signed in verified user' do
  let(:user) do
    FactoryGirl.create(:verified_user)
  end

  before do
    clean_models User
    log_in_user(user)
  end

  after do
    clean_models User
  end
end

shared_context 'signed in provisional user' do
  let(:user) do
    FactoryGirl.create(:new_user)
  end

  before do
    clean_models User
    log_in_user(user)
  end

  after do
    clean_models User
  end
end