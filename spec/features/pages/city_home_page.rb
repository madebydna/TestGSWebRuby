require_relative './modules/email_join_modal'
require_relative './modules/flash_messages'

class CityHomePage < SitePrism::Page
  include EmailJoinModal
  include FlashMessages

  element :email_signup_section, '.js-shared-email-signup'

  context 'when I click the "sign up for email updates" button', js: true do
    before { page_object.email_signup_section.submit_button.click }
    after { clean_dbs :gs_schooldb }
    with_subject(:email_join_modal) do
      it { is_expected.to be_visible }
      when_I :sign_up_with_email, 'email@example.com' do
        its(:parent_page) { is_expected.to have_flash_message('You\'ve signed up to receive updates.') }
      end
    end
  end

  with_shared_context 'signed in verified user', js: true do
    context 'when I click the "sign up for email updates" button' do
      before do
        visit home_path
        page_object.email_signup_section.submit_button.click
      end
      after { clean_dbs :gs_schooldb }
      it { is_expected.to_not have_email_join_modal }
      it { is_expected.to have_flash_message('You\'ve signed up to receive updates.') }
    end
  end
end