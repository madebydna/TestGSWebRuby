require 'spec_helper'
require 'features/page_objects/user_email_preferences_page'
require 'features/page_objects/join_page'
require 'features/page_objects/home_page'
require 'features/page_objects/user_email_unsubscribes_page'
require 'features/examples/footer_examples'

describe 'unsubscribe page' do

  subject(:page_object) do
    UserEmailUnsubscribesPage.new
  end

  let(:user) { FactoryBot.create(:user, id: 1) }
  
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
    include_examples 'should have a footer'

    when_I :unsubscribe_from_emails, js: true do
      it 'should display preferences page' do
        preferences_page = UserEmailPreferencesPage.new
        expect(preferences_page).to be_displayed
      end
    end

    when_I :click_manage_preferences, js: true do
      it 'should display preferences page' do
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
