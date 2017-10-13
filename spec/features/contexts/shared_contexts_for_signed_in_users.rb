def log_in_user(user)
  auth_token = UserAuthenticationToken.new(user).generate
  set_cookie('auth_token', auth_token)
  set_cookie('MEMID', user.id)
  set_cookie('community_www', auth_token.gsub('=', '~'))
end

def log_out_user
  clear_cookies
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
