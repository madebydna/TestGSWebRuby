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

  describe 'Profile grade levels' do
    let(:content) { subject.grade_level_subscriptions.content }
    
    before do
      sign_in_as_testuser
      subject.load
    end

    it 'should subscribe user to a single grade-level' do
      confirm_unchecked_and_check("third_grade")
      sleep(2) # wait for ajax requests
      subject.load
      confirm_checked_and_uncheck("third_grade")
      sleep(2)
    end

    it 'should subscribe user to multiple grade-levels at once' do
      ["pk", "first_grade", "twelfth_grade"].each do |grade|
        confirm_unchecked_and_check(grade)
      end
      sleep(2)
      subject.load
      ["pk", "first_grade", "twelfth_grade"].each do |grade|
        confirm_checked_and_uncheck(grade)
      end
      sleep(2)
    end
      
    it 'should unsubscribe user from a single grade-level' do
      confirm_unchecked_and_check("fifth_grade")
      sleep(2)
      subject.load
      # now user is subscribed
      confirm_checked_and_uncheck("fifth_grade")
      sleep(2)
      subject.load
      # now user is unsubscribed - confirm
      cb = content.find_input("fifth_grade")
      expect(cb).not_to be_checked
    end

    it 'should unsubscribe user from multiple grade-levels at once' do
      %w(kg second_grade seventh_grade).each do |grade|
        confirm_unchecked_and_check(grade)
      end
      sleep(2)
      subject.load
      %w(kg second_grade seventh_grade).each do |grade|
        confirm_checked_and_uncheck(grade)
      end
      sleep(2)
      subject.load
      # now user is unsubscribed - confirm
      %w(kg second_grade seventh_grade).each do |grade|
        cb = content.find_input(grade)
        expect(cb).not_to be_checked
      end
    end

    def confirm_checked_and_uncheck(grade)
      cb = content.find_input(grade)
      expect(cb).to be_checked
      content.check_or_uncheck_checkbox(grade)
    end
    
    def confirm_unchecked_and_check(grade)
      cb = content.find_input(grade)
      expect(cb).not_to be_checked
      content.check_or_uncheck_checkbox(grade) 
    end
  end

  describe 'Email subscriptions' do
    let(:content) { subject.email_subscriptions.content }

    def load_page_and_open_email_section
      subject.load
      subject.email_subscriptions.closed_arrow.click
      subject.email_subscriptions.wait_until_content_visible
    end

    before do
      sign_in_as_testuser
      load_page_and_open_email_section
    end

    it 'should subscribe user to greatnews newsletter' do
      expect(content.greatnews_checkbox).not_to be_checked
      content.greatnews_checkbox.check
      load_page_and_open_email_section
      expect(content.greatnews_checkbox).to be_checked
      content.greatnews_checkbox.uncheck
    end

    it 'should unsubscribe user from greatnews newsletter' do
      content.greatnews_checkbox.check
      load_page_and_open_email_section
      expect(content.greatnews_checkbox).to be_checked # user is subscribed
      content.greatnews_checkbox.uncheck # now unsubscribe
      load_page_and_open_email_section
      expect(content.greatnews_checkbox).not_to be_checked # check that user is still unsubscribed
    end

    it 'should subscribe user to sponsor newsletter' do
      expect(content.sponsor_checkbox).not_to be_checked
      content.sponsor_checkbox.check
      load_page_and_open_email_section
      expect(content.sponsor_checkbox).to be_checked
      content.sponsor_checkbox.uncheck
    end

    it 'should unsubscribe user from sponsor newsletter' do
      content.sponsor_checkbox.check
      load_page_and_open_email_section
      expect(content.sponsor_checkbox).to be_checked # user is subscribed
      content.sponsor_checkbox.uncheck # now unsubscribe
      load_page_and_open_email_section
      expect(content.sponsor_checkbox).not_to be_checked # check that user is still unsubscribed
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