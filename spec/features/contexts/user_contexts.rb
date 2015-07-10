require 'spec_helper'

shared_context 'signed in regular user with' do |user_args|
  before do
    user = FactoryGirl.create(:user, user_args)
    log_in_user(user)
  end
  after { clean_models :gs_schooldb, User }
end