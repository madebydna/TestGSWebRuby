require 'spec_helper'
require 'features/page_objects/user_email_preferences_page'
require 'features/contexts/shared_contexts_for_signed_in_users'

describe 'User email preferences page' do
  with_shared_context 'signed in verified user', js: true do
    before { visit user_preferences_path }
    subject(:page_object) { UserEmailPreferencesPage.new }
    it { is_expected.to have_preferences_form }
    its(:preferences_form) { is_expected.to have_submit_button }
  end
end
