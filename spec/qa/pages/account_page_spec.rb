require 'qa/spec_helper_qa'
require 'features/page_objects/account_page'
require 'features/page_objects/join_page'

describe 'Account page', remote: true do
  subject { AccountPage.new }

  describe 'basic layout' do
    before do
      sign_in_as_testuser
      subject.load
    end

    it { is_expected.to be_displayed }

    it 'should display user email' do
      expect(subject).to have_text("qa-testuser@greatschools.org")
    end
  end

  describe 'Password change form' do
    let(:content) { subject.change_password.content }

    describe "validations" do
      before do
        sign_in_as_testuser
        subject.load
      end

      it 'should require user to set a new password' do
        subject.change_password.closed_arrow.click
        content.submit_btn.click
        expect(content).to have_text(/Please specify a new password/)
        expect(content).not_to have_confirmation
      end

      it 'should require user to set a password confirmation' do
        subject.change_password.closed_arrow.click
        content.password_field.set("foobar")
        content.submit_btn.click
        expect(content).to have_text(/The passwords do not match/)
        expect(content).not_to have_confirmation
      end

      it 'should require the password to match confirmation' do
        subject.change_password.closed_arrow.click
        content.password_field.set("foobar")
        content.password_confirmation_field.set("foobaz")
        content.submit_btn.click
        expect(content).to have_text(/The passwords do not match/)
        expect(content).not_to have_confirmation
      end
    end

    context 'Initially setting password for unverified user' do
      before do
        @email = random_email
        register_new_user(email: @email)
        sleep(2)
      end

      # Unverified user need to set a password after verification,
      # even if they have set one

      it 'should allow user to set password' do
        subject.load
        expect(subject).to have_text(@email)
        change_password_to("secret123")
        expect(content).to have_confirmation
        logout_user
        confirm_login_with_password(email: @email, password: 'secret123')
      end
    end

    context 'Changing password for verified user' do
      before do
        sign_in_as_testuser
        subject.load
      end

      it 'should allow changing user password' do
        change_password_to("mysupersecret")
        expect(content).to have_confirmation
        logout_user
        confirm_login_with_password(email: 'qa-testuser@greatschools.org', password: 'mysupersecret')
        change_password_to("secret123")
      end
    end

    def change_password_to(new_password)
      subject.change_password.closed_arrow.click
      content.password_field.set(new_password)
      content.password_confirmation_field.set(new_password)
      content.submit_btn.click
    end

    def confirm_login_with_password(email:, password:)
      sign_in_user(email: email, password: password)
      # confirm user is logged in
      subject.load
      expect(subject).to have_text(email)
    end
  end
end