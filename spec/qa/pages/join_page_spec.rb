require 'features/page_objects/join_page'
require 'features/page_objects/home_page'
require 'features/page_objects/account_page'
require 'features/page_objects/school_profiles_page'
require 'features/page_objects/forgot_password_page'

describe 'User Registration Flows', remote: true do
  let(:join_page) { JoinPage.new }
  let(:home_page) { HomePage.new }
  let(:account_page) { AccountPage.new }
  let(:menu) { home_page.top_nav.menu }

  describe 'Facebook signin', remote: true do
    before { join_page.load }
    
    it 'should redirect to account page with user\'s name' do
       facebok_window = window_opened_by do
        join_page.facebook_button.click
       end
       within_window facebok_window do
        submit_facebook_adam
       end
       expect(page).to have_text('Adam')
       expect(page.current_path).to eq('/account/')
     end
  end

  describe 'Signing in as an existing user' do
    before do 
      sign_in_as_testuser
    end

    it 'should redirect to the home page' do
      expect(home_page).to be_loaded
    end

    it 'should have a link to My Account' do
      expect(menu).to have_account_link
    end

    it 'should have a link to Sign Out' do
      expect(menu).to have_logout_link
    end
  end

  describe 'Signing up as a new user' do
    before do 
      clear_cookies
      @email = random_email
    end

    context 'via Sign Up link in header' do
      before do
        home_page.load
        menu.signin_link.click
        # this loads the join page
        register_new_user(email: @email, load_join_page: false)
      end

      it 'should redirect to the home page' do
        expect(home_page).to be_loaded
      end

      it 'should have a link to My Account' do
        expect(menu).to have_account_link
      end

      it 'should have a link to Sign Out' do
        expect(menu).to have_logout_link
      end

      # Activation related specs to be found in 
      # spec/features/pages/join_page_spec.rb
    end

    # context via OSP page ... see osp_register_page_spec.rb

    context 'on school profile page' do
      let(:school_page) { SchoolProfilesPage.new }
      let(:hero_links) { school_page.hero_links }
      let(:review_form) { school_page.review_form }
      let(:menu) { school_page.top_nav.menu }
      
      context 'via leaving a review' do
        before do
          school_page.load(state: 'california', city: 'alameda', 
            school_id_and_name: '1-Alameda-High-School')
            @email = random_email
        end

        it 'submits review and signs up user' do
          review_form.five_star_rating.click
          begin
            review_form.wait_until_questions_visible
          rescue SitePrism::ElementVisibilityTimeoutError
            save_and_open_screenshot
          end
          review_form.rate_your_experience_textarea.set('This is a comment generated by rspec ' + Time.now.to_s)
          review_form.submit_form
          register_in_modal(email: @email)
          school_page.wait_until_relationship_to_school_modal_visible
          school_page.relationship_to_school_modal.parent.click
          school_page.relationship_to_school_modal.submit_button.click
          sleep(2)
          expect(school_page).to have_text('Thank you! One more step - please click on the verification link')
        end
      end
  
      context 'via saving a school on school\'s profile' do
        before do
          school_page.load(state: 'california', city: 'alameda', 
            school_id_and_name: '1-Alameda-High-School')
            @email = random_email
        end
  
        it 'saves school and signs up user' do
          hero_links.save_school_link.click
          expect(school_page).to have_saved_school_modal
          school_page.saved_school_modal.sign_up(@email, [], false)
          expect(school_page).to have_saved_school_success_modal
          school_page.close_all_modals
          expect(menu.saved_schools_link).to have_text(/\(1\)/)
          account_page.load
          expect(account_page).to be_loaded
          expect(account_page).to have_text(@email)
        end
      end
    end

    context 'via newsletter link in footer' do
      before do
        @email = random_email
        home_page.load
        home_page.footer.newsletter_link.click
      end

      it 'creates user account' do
        home_page.email_newsletter_modal.sign_up(@email, [], false)
        expect(home_page).to have_newsletter_success_modal
        account_page.load
        expect(account_page).to be_loaded
        expect(account_page).to have_text(@email)
      end

      # Note: details on testing subscriptions to grade-level emails
      # and partner offers to be found regular feature tests
      # features/pages/home_page_spec.rb
    end
  end

  describe 'Forgot Password Link' do
    let(:forgot_password_page) { ForgotPasswordPage.new }
    before do
      join_page.load
    end

    it 'opens the forgot password flow' do
      join_page.click_forgot_password_link
      expect(forgot_password_page).to be_loaded
      forgot_password_page
        .fill_in_email_field("qa-testuser@greatschools.org")
      forgot_password_page.click_continue_button
      expect(join_page).to be_loaded
      join_page.wait_until_flash_messages_visible
      msg = "Great! Just click on the link \
      in the email we sent to qa-testuser@greatschools.org \
      to continue resetting your password.".squish
      expect(join_page.flash_messages.first.text).to match(msg)
    end

    # Note: full flow of password reset email tested in 
    # spec/features/pages/forgot_password_page_spec.rb
  end
end