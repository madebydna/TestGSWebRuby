require 'remote_spec_helper'

describe 'newsletters', type: :feature, remote: true do
  context 'on the home page' do
    before { visit '/' }
    feature 'I can click newsletter link in footer to sign up' do
      before do
        within('footer') { click_link 'Newsletter' }
      end
      it 'I should see the newsletter modal' do
        within('.remodal') do
          expect(page).to have_content(
            'Get our best articles, worksheets, and more delivered weekly to your inbox.'
          )
        end
      end
    end
  end

  context 'on Alameda High School' do
    before { visit '/california/alameda/1-Alameda-High-School/' }
    feature 'I can click newsletter link in sticky CTA to sign up' do
      before do
        within('#profile-sticky-container') { click_link 'Save' }
      end
      it 'I should see the newsletter modal' do
        within('.remodal') do
          expect(page).to have_content('Yes! Send me email updates about my child\'s school')
        end
      end
      it 'I can sign up and see school on my account page' do
        within('.remodal') do
          email = "ssprouse+rspec_#{Time.now.strftime('%s')}@greatschools.org"
          fill_in('email', with: email)
          click_button('Sign up')
        end
        sleep 10 # need to wait long enough for modal ajax call to complete and save database records
        visit '/account/'
        # should force capybara to wait at least a couple seconds for this to appear
        expect(page).to have_content('My School List') 

        within(:xpath, '/html/body/div[8]') do
          expect(page).to have_content('Alameda High School')
        end

        page.execute_script("$('.i-32-close-arrow-head').trigger('click');") # tried geting elements and using capybara click, didnt work
        expect(page).to have_content('Alameda High School, Alameda , CA') # tests for MSS subscription
        expect(find('#greatnews')).to be_checked
      end
    end

  end
end
