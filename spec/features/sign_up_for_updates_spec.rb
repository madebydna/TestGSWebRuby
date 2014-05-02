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

  describe 'Connect With Us' do
    it 'should say "Connect with us"'
    it 'should have facebook logo'
    it 'should have twitter logo'
    it 'should have pinterest logo'
    it 'should have greatschools blog logo'
    it 'should have youtube logo'
  end
end