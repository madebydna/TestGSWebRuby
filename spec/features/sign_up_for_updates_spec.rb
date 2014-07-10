require 'spec_helper'
#require 'sample_data_helper'

describe 'Sign Up For Updates Partial', :type => :feature do
  context 'When on a public school profile page' do


    describe 'Sign Up' do

      #let(:city_page_url) { '/michigan/detroit/1078-Chrysler-Elementary-School' }
      #before { visit school_url }
      #
      it 'should have Sign Up button' #do
  #      expect(page).to have_css('.js-send-me-updates-button-footer')
  #    end
      it 'should say "Sign up for email updates"' #do
  #      expect(page).to have_content 'Sign up for email updates'
  #    end
    end
  end

  context 'When on Rorr home page', js: true do
    let(:home_prototype) { '/gsr/home' }
    before(:each) { visit home_prototype_path }

    describe 'Sign up' do
      it 'browse button should go to join url' do
           click_button('browse-sign-up')
           expect(page).to have_css('.js-join-tab.active')
           expect(page).to_not have_css('.js-login-tab.active')
      end

      it 'footer button should go to join url' do
        click_button('footer-sign-up')
        expect(page).to have_css('.js-join-tab.active')
        expect(page).to_not have_css('.js-login-tab.active')
      end

    end

# TODO: need to write a test for mystery sign up button on _email_signup.html
  end

  describe 'Connect With Us' do
    it 'should say "Connect with us"'
    it 'should have facebook logo'
    it 'should have twitter logo'
    it 'should have pinterest logo'
    it 'should have greatschools blog logo'
    it 'should have youtube logo'
  end
end