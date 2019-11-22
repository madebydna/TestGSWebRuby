require 'spec_helper'
require 'features/page_objects/forgot_password_page'
require 'features/page_objects/join_page'
require 'features/examples/footer_examples.rb'

describe 'Reset password page' do

  subject(:page_object) do
    JoinPage.new
  end

    before do
      visit '/gsr/login/'
    end

    it { is_expected.to be_displayed }
    it { is_expected.to have_forgot_password_link }

    include_examples 'should have a footer'

    when_I :click_forgot_password_link, js: true do
      it 'should display the forgot password page' do
        expect(ForgotPasswordPage.new).to be_displayed
      end
    end

end
