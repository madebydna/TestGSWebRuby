def log_in_user(user)
  host = Capybara.app_host ? URI(Capybara.app_host).host : '127.0.0.1'
  auth_token = UserAuthenticationToken.new(user).generate

  if page.driver.class.name == 'Capybara::Webkit::Driver'
    cookie_settable = page.driver
  else
    cookie_settable = page.driver.browser
  end
  cookie_settable.set_cookie("auth_token=#{auth_token}; domain=#{host}")
  cookie_settable.set_cookie("MEMID=#{user.id}; domain=#{host}")
  cookie_settable.set_cookie("community_www=#{auth_token.gsub('=', '~')}; domain=#{host}")
end

def log_out_user
  if page.driver.class.name == 'Capybara::Webkit::Driver'
    cookie_settable = page.driver
  else
    cookie_settable = page.driver.browser
  end
  cookie_settable.clear_cookies
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
    log_out_user
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
    log_out_user
    clean_models User
  end
end
