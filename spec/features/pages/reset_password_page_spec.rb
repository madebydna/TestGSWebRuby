require 'spec_helper'
require 'features/page_objects/reset_password_page'
require 'features/page_objects/join_page'
require 'features/page_objects/account_page'
require 'features/contexts/shared_contexts_for_signed_in_users'
require 'features/examples/footer_examples.rb'

describe 'Reset password page' do

  subject(:page_object) do
    ResetPasswordPage.new
  end

  with_shared_context 'signed in verified user' do
    context 'visit the reset password page' do
      before do
        visit '/account/password/'
      end
      include_examples 'should have a footer'
      it { is_expected.to be_displayed }
      it { is_expected.to have_heading }
      it { is_expected.to have_reset_password_form }

      when_I :fill_in_a_password do
        when_I :click_the_submit_button do
          it 'should display the account page' do
            expect(AccountPage.new).to be_displayed
          end
        end
      end

      when_I :fill_in_a_password_mismatch do
        when_I :click_the_submit_button do
          it 'should display the reset password page' do
            expect(ResetPasswordPage.new).to be_displayed
          end
          it 'should show a parsley values not the same error', js: true do
            expect(subject).to have_passwords_not_match_error
          end
        end
      end

      when_I :fill_in_a_too_short_password do
        when_I :click_the_submit_button do
          it 'should display the reset password page' do
            expect(ResetPasswordPage.new).to be_displayed
          end
          it 'should show parsley length invalid error', js: true do
            expect(subject).to have_invalid_password_length_error
          end
        end
      end
    end
  end

  context 'not signed in' do
    before do
      visit '/account/password/'
    end
    it { is_expected.to_not be_displayed }
    it 'should display the join page' do
      expect(JoinPage.new).to be_displayed
    end
  end

end
