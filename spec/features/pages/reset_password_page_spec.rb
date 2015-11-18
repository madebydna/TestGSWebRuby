require 'spec_helper'
require_relative 'reset_password_page'
require_relative 'join_page'
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