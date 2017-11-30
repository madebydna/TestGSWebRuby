require 'spec_helper'

shared_context 'signed in regular user with' do |user_args|
  before do
    user = FactoryGirl.create(:user, user_args)
    log_in_user(user)
  end
  after do
    log_out_user
    clean_models :gs_schooldb, User
  end
end
