require 'spec_helper'
require_relative 'forgot_password_page'
require_relative 'join_page'

describe 'Reset password page' do

  subject(:page_object) do
    JoinPage.new
  end

    before do
      visit '/gsr/login/'
    end

    it { is_expected.to be_displayed }
    it { is_expected.to have_forgot_password_link }

    when_I :click_forgot_password_link, js: true do
      it 'should display the forgot password page' do
        expect(ForgotPasswordPage.new).to be_displayed
      end

    end

end
