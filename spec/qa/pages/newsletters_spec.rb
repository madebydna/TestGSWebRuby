require 'qa/spec_helper_qa'
require 'features/page_objects/email_preferences_page'

describe 'Newsletters', remote: true do
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

  context 'on Alameda High School', type: :feature, js: true do
    before { visit '/california/alameda/1-Alameda-High-School/' }
    feature 'I can click newsletter link in sticky CTA to sign up' do
      let(:preferences_page) { EmailPreferencesPage.new }

      before do
        find('a.js-followThisSchool', match: :first).click
      end

      it 'I should see the newsletter modal' do
        within('.remodal') do
          expect(page).to have_content('Yes! Send me email updates about my child\'s school')
        end
      end

      it 'I can sign up and see school and greatnews subscription on my email preferences page' do
        register_in_modal
        sleep 10 # need to wait long enough for modal ajax call to complete and save database records
        preferences_page.load
        expect(preferences_page).to have_school_updates

        alameda_high_sub = preferences_page.school_updates.school_subscriptions.detect do |el|
          el[:class].include?("active") &&
          el["data-state"] == "CA" &&
          el["data-school-id"].to_i == 1
        end
        expect(alameda_high_sub).to be_truthy

        greatnews_sub = preferences_page.english.weekly
        expect(preferences_page.subscribed?(greatnews_sub)).to be true
      end
    end

  end
end
