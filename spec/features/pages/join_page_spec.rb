require 'spec_helper'
require 'features/page_objects/forgot_password_page'
require 'features/page_objects/join_page'
require 'features/page_objects/home_page'
require 'features/page_objects/account_page'
require 'features/examples/footer_examples.rb'

describe 'Join page', js: true do

  subject { JoinPage.new }

  before do
    subject.load
  end

  it { is_expected.to be_displayed }
  it { is_expected.to have_forgot_password_link }

  include_examples 'should have a footer'

  when_I :click_forgot_password_link, js: true do
    let(:page_object) { ForgotPasswordPage.new }
    it 'should display the forgot password page' do
      expect(page_object).to be_displayed
    end
  end

  describe 'new user activation' do
    let(:sent_email) { ExactTarget.last_delivery_args }
    before do
      @email = random_email
      register_new_user(email: @email)
      subject.wait_until_flash_messages_visible
    end

    after { clean_dbs :gs_schooldb }

    it 'should indicate sucess' do
      msg = "Almost done! Now you just need you to verify \
      your email address. Please click on the link in the email \
      to activate your account.".squish
      expect(subject.flash_messages.first.text).to match(msg)
    end

    it 'should send activation email' do
      expect(sent_email).to be_present
      expect(sent_email[:key]).to eq(EmailVerificationEmail.exact_target_email_key)
    end

    describe 'activation' do
      before do
        link = sent_email[:attributes][:VERIFICATION_LINK]
        visit(link)
      end

      it 'should prompt user to set password' do
        fill_in "New password", with: 'secret123'
        fill_in "Confirm password", with: 'secret123'
        click_on 'Submit'
        expect(AccountPage.new).to be_loaded
      end

      it 'should activate user' do
        user = User.find_by(email: @email)
        expect(user.email_verified).to be true
      end

    end

  end

end
