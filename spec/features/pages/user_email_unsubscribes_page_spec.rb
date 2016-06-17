require 'spec_helper'
require 'features/page_objects/user_email_preferences_page'
require 'features/page_objects/join_page'
require 'features/page_objects/user_email_unsubscribes_page'

describe 'unsubscribe page' do

  subject(:page_object) do
    UserEmailUnsubscribesPage.new
  end

  let(:user) { FactoryGirl.create(:user, id: 1) }
  after do
    clean_dbs(:gs_schooldb)
  end

  context 'with valid user token' do
    before do
      valid_token = UserVerificationToken.token(user.id)
      visit '/unsubscribe/?token=' + valid_token
    end

    it { is_expected.to be_displayed }
    it { is_expected.to have_unsubscribe }
    it { is_expected.to have_manage_preferences }

    when_I :unsubscribe_from_emails do
      it 'should display success message' do
        pending('need to fix flash message')
        fail
        message = 'You have unsubscribed from all GreatSchool emails'
        expect(subject).to have_flash_message(message)
      end
    end

    when_I :click_manage_preferences, js: true do
      it 'should display home page' do
        expect(UserEmailPreferencesPage.new).to be_displayed
      end
    end
  end

  context 'with invalid user token' do
    before do
      invalid_token = 'invalid'
      visit '/unsubscribe/?token=' + invalid_token
    end
    it 'should display join page' do
      expect(JoinPage.new).to be_displayed
    end
  end
end
