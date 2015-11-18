require 'spec_helper'
require_relative 'reset_password_page'
require_relative 'join_page'
require_relative 'account_page'
require 'support/shared_contexts_for_signed_in_users'

describe 'Reset password page' do

  subject(:page_object) do
    ResetPasswordPage.new
  end

  with_shared_context 'signed in verified user' do
    context 'visit the reset password page' do
      before do
        visit '/account/reset-password/'
      end
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
          it 'should show a flash error: The passwords do not match', js: true do
            expect(subject).to have_flash_error(I18n.t('models.reset_password_params.password_mismatch'))
          end
        end
      end

      when_I :fill_in_a_too_short_password do
        when_I :click_the_submit_button do
          it 'should display the reset password page' do
            expect(ResetPasswordPage.new).to be_displayed
          end
          it 'should show flash error: Your password must be between 6 and 14 characters.', js: true do
            expect(subject).to have_flash_error(I18n.t('models.reset_password_params.password_too_short'))
          end
        end
      end
    end
  end

  context 'not signed in' do
    before do
      visit '/account/reset-password/'
    end
    it { is_expected.to_not be_displayed }
    it 'should display the join page' do
      expect(JoinPage.new).to be_displayed
    end
  end

end