require 'spec_helper'
require_relative '../../../spec/support/shared_contexts_for_signed_in_users'


shared_context 'signed in approved osp user for school' do |state, school_id|
  before do
    user = FactoryGirl.create(:verified_user)
    FactoryGirl.create(:esp_membership,:with_approved_status, member_id: user.id, state: state, school_id: school_id )

    log_in_user(user)
  end

  after do
    clean_models User, EspMembership
  end
end