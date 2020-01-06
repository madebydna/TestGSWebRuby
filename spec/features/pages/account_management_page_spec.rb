require 'spec_helper'
require 'features/contexts/shared_contexts_for_signed_in_users'
require 'features/examples/footer_examples'
require 'features/page_objects/account_page'
require 'features/page_objects/join_page'

describe 'Account management page', js: true do
  let(:login_page) { JoinPage.new }
  subject { AccountPage.new }

  after do
    clean_dbs :gs_schooldb
  end

  describe 'requires user to be logged in' do
    context 'when user is not logged in' do
      it 'should return to the login page' do
        subject.load
        expect(login_page).to be_loaded
      end
    end
  end

  describe 'A registered and verified user' do
    include_context 'signed in verified user'

    context 'when user has approved osp membership' do
      before do
        FactoryBot.create(:esp_membership, :with_approved_status, member_id: user.id )
        subject.load
      end

      scenario 'It displays link to edit osp' do
        expect(subject).to be_loaded
        expect(subject).to have_content("Edit School Profile")
      end
    end

    context 'when user has provisional osp membership' do
      before do
        FactoryBot.create(:esp_membership,:with_provisional_status, member_id: user.id, school_id: 1, state: 'mi')
        subject.load
      end

      scenario 'It displays link to edit osp' do
        expect(subject).to have_content('Edit School Profile')
      end
    end

    context 'when user is osp super user' do
      before do
        esp_superuser_role = FactoryBot.create(:role)
        FactoryBot.create(:member_role,member_id: user.id,role_id:esp_superuser_role.id)
        subject.load
      end

      scenario 'It displays link to edit osp' do
        expect(subject).to have_content('Edit School Profile')
      end
    end

    context 'When user has subscriptions' do
      let(:content) { subject.email_subscriptions.content }
      before do
        FactoryBot.create(:subscription, list: 'osp', member_id: user.id)
        FactoryBot.create(:subscription, list: 'greatnews', member_id: user.id)
        subject.load
        subject.email_subscriptions.closed_arrow.click
        subject.email_subscriptions.wait_until_content_visible
      end

      it 'should indicate subscriptions' do
        expect(user.subscriptions.size).to eq(2)
        expect(content.greatnews_checkbox).to be_checked
        expect(content.osp_checkbox).to be_checked
      end

      it 'should allow user to unsubscribe ' do
        expect do
          content.greatnews_checkbox.uncheck
          sleep(3)
        end.to change(user.subscriptions, :count).by(-1)
      end
    end

    context 'with no user profile' do
      # TODO: Is this still meaningful? What is a user profile used for?
      before do 
        user.user_profile.destroy
        subject.load
      end
      it 'still displays the password reset form' do
        save_and_open_screenshot
        expect(subject).to have_change_password
      end
    end
  end
end
