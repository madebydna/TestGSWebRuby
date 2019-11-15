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
      before do
        find('a.js-followThisSchool', match: :first).click
      end
      it 'I should see the newsletter modal' do
        within('.remodal') do
          expect(page).to have_content('Yes! Send me email updates about my child\'s school')
        end
      end
      it 'I can sign up and see school on my account page' do
        register_in_email_modal
        sleep 10 # need to wait long enough for modal ajax call to complete and save database records
        visit '/account/'
        # should force capybara to wait at least a couple seconds for this to appear
        expect(page).to have_content('My School List')

        within('.drawer', text: /Email Subscriptions/) do
          arrow = find('.i-32-close-arrow-head', match: :first)
          arrow.click
        end

        expect(find('input[name="greatnews"]', match: :first)).to be_checked
        expect(page).to have_content('Alameda High School') # tests for MSS subscription
      end
    end

  end
end
