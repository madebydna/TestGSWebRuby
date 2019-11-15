require 'spec_helper'
require 'features/page_objects/user_email_preferences_page'
require 'features/contexts/shared_contexts_for_signed_in_users'
require 'features/examples/footer_examples'

describe 'User email preferences page' do
  subject(:page_object) do
    visit user_preferences_path
    UserEmailPreferencesPage.new
  end

  with_shared_context 'signed in verified user', js: true do
    it { is_expected.to have_preferences_form }
    its(:preferences_form) { is_expected.to have_submit_button }
    include_examples 'should have a footer'
  end

end