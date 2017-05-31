require 'remote_spec_helper'
require 'features/page_objects/school_profiles_page'

describe 'school name shows up on a preschool profile', type: :feature, remote: true, safe_for_prod: true do
  before { visit '/new-jersey/newark/preschools/Broadway-Mini-Mall-Head-Start/7453/' }
  subject(:page_object) { SchoolProfilesPage.new }
  its(:h1) { is_expected.to have_text('Broadway Mini Mall Head Start') }
end

describe 'I can view profiles for schools in cities with hyphenated names', type: :feature, remote: true, safe_for_prod: true do
  subject { page }
  context 'New York' do
    before { visit '/new-york/new-york/1811-Beacon-High-School/reviews/' }
    it { is_expected.to have_text('Beacon High School') }
  end
  context 'North Carolina' do
    before { visit '/north-carolina/kernersville/11160-The-North-Carolina-Leadership-Academy/' }
    it { is_expected.to have_text('The North Carolina Leadership Academy') }
  end
end


# Don't tag tests that write reviews to DB as safe_for_prod
describe 'submit a review while signed out', type: :feature, remote: true do
  it 'submits the review after signing in with facebook' do
    pending 'Need to allow all facebook urls in the correct spec helper file. But still doesn\'t work. Enable webkit debug and see logs.'
    fail
    # within('.join-and-login') do
    #   click_button 'Sign up with facebook'
    # end
    # submit_facebook_adam
    # page.should have_content('All set! We have submitted your review. Thank you for helping other families by sharing your experiences.
  end
end

# Don't tag tests that write reviews to DB as safe_for_prod
describe 'while signed in as facebook user', type: :feature, remote: true do
  it 'when I submit a review it is acknowledged' do
    sign_in_as_facebook_adam
    visit('/california/alameda/1-Alameda-High-School/')
    first('.five-star-question-cta__star').click
    within('.review-form') do
      all('textarea').last.set('this is a comment generated by rspec ' + Time.now.to_s)
      click_button('Submit')
    end
    if has_css?('.modal')
      within('.modal') do
        find('div[data-school-user=parent]').click
        click_button('Submit review')
      end
    end
    
    expect(page).to have_text('All set! We have submitted your review')
  end

  it 'when I save the school the right newsletters are saved' do
    sign_in_as_facebook_adam
    visit('/california/alameda/1-Alameda-High-School/')
    first('.js-followThisSchool').click
    visit '/account/'
    page.first('div', text: 'Email Subscriptions').click
    expect(page).to have_text('Alameda High School, Alameda , CA')
  end

  it 'when I save the school it is added to my school list' do
    sign_in_as_facebook_adam
    visit('/california/alameda/1-Alameda-High-School/')
    first('.js-followThisSchool').click
    visit '/account/'
    # assuming that the school's address only shows up in the school list card
    expect(page).to have_text('2201 Encinal Avenue, Alameda, CA 94501')
  end
end

describe 'follow a school while registering', type: :feature, remote: true do
  it 'when I save the school the right newsletters are saved' do
    visit('/california/alameda/1-Alameda-High-School/')
    first('.js-followThisSchool').click
    register_in_email_modal
    sleep 2
    visit '/account/'
    page.first('div', text: 'Email Subscriptions').click
    expect(page).to have_text('Alameda High School, Alameda , CA')
  end

  it 'when I save the school it is added to my school list' do
    visit('/california/alameda/1-Alameda-High-School/')
    first('.js-followThisSchool').click
    register_in_email_modal
    sleep 2
    visit '/account/'
    page.first('div', text: 'Email Subscriptions').click
    # assuming that the school's address only shows up in the school list card
    expect(page).to have_text('2201 Encinal Avenue, Alameda, CA 94501')
  end
end

# Don't tag tests that write reviews to DB as safe_for_prod
describe 'submit a review while registering', type: :feature, remote: true do
  it 'show indicate my review is saved and ask me to verify my email' do
    visit('/california/alameda/1-Alameda-High-School/')
    first('.five-star-question-cta__star').click

    within('.review-form') do
      all('textarea').last.set('this is a comment generated by rspec ' + Time.now.to_s)
      click_button('Submit')
    end

    register_in_modal

    sleep 2

    within('.modal') do
      find('div[data-school-user=parent]').click
      click_button('Submit review')
    end
    
    sleep 2

    expect(page).to have_text('Thank you! One more step - please click on the verification link')
  end
end
