
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
    pending 'Facebook login fails'
    fail
    # sign_in_as_ssprouse
    # visit('/california/alameda/1-Alameda-High-School/')
    # first('.five-star-question-cta__star').click
    # within('.review-form') do
    #   all('textarea').last.set('this is a comment generated by rspec ' + Time.now.to_s)
    #   click_button('Submit')
    # end
    # if has_css?('.remodal')
    #   within('.remodal') do
    #     find('div[data-school-user=parent]').click
    #     click_button('Submit review')
    #   end
    # end
    #
    # expect(page).to have_text('All set! We have submitted your review')
  end

  it 'when I save the school the right newsletters are saved and it is added to my school list' do
    pending 'Facebook login fails'
    sign_in_as_ssprouse
    visit('/california/alameda/1-Alameda-High-School/')
    first('.js-followThisSchool').click
    expect(page).to have_text('Good news! You’re signed up to receive our newsletter and updates on Alameda High School')
    visit '/account/'
    page.first('div', text: 'Email Subscriptions').click
    expect(page.has_checked_field?('mystat')).to be_truthy
    expect(page.has_checked_field?('greatnews')).to be_truthy
    expect(page.has_checked_field?('sponsor')).to be_falsey
    # assuming that the school's address only shows up in the school list card
    expect(page).to have_text('2201 Encinal Avenue, Alameda, CA 94501')
  end

  it 'when I click the newsletter link in the footer, the right newsletters are saved and it is added to my school list' do
    pending 'Facebook login fails'
    sign_in_as_ssprouse
    visit('/california/alameda/1-Alameda-High-School/')
    within('footer') { click_link 'Newsletter' }
    expect(page).to have_text('Good news! You’re signed up to receive our newsletter and updates on Alameda High School')
    visit '/account/'
    page.first('div', text: 'Email Subscriptions').click
    expect(page.has_checked_field?('mystat')).to be_truthy
    expect(page.has_checked_field?('greatnews')).to be_truthy
    expect(page.has_checked_field?('sponsor')).to be_falsey
    # assuming that the school's address only shows up in the school list card
    expect(page).to have_text('2201 Encinal Avenue, Alameda, CA 94501')
  end
end

describe 'follow a school while registering', type: :feature, remote: true do
  it 'when I save the school the right newsletters are saved and it is added to my school list' do
    visit('/california/alameda/1-Alameda-High-School/')
    first('.js-followThisSchool').click
    register_in_email_modal
    sleep 2
    expect(page).to have_text('All set! You are signed up for our newsletter and updates on Alameda High School')
    visit '/account/'
    page.first('div', text: 'Email Subscriptions').click
    expect(page.has_checked_field?('mystat')).to be_truthy
    expect(page.has_checked_field?('greatnews')).to be_truthy
    expect(page.has_checked_field?('sponsor')).to be_truthy
    expect(page).to have_text('Alameda High School, Alameda , CA')
  end

  it 'when I click the newsletter link in the footer the right newsletters are saved and it is added to my school list' do
    visit('/california/alameda/1-Alameda-High-School/')
    within('footer') { click_link 'Newsletter' }
    register_in_email_modal
    sleep 2
    expect(page).to have_text('All set! You are signed up for our newsletter and updates on Alameda High School')
    visit '/account/'
    page.first('div', text: 'Email Subscriptions').click
    expect(page.has_checked_field?('mystat')).to be_truthy
    expect(page.has_checked_field?('greatnews')).to be_truthy
    expect(page.has_checked_field?('sponsor')).to be_truthy
    expect(page).to have_text('Alameda High School, Alameda , CA')
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

    within('.remodal') do
      find('div[data-school-user=parent]').click
      click_button('Submit review')
    end
    
    sleep 2

    expect(page).to have_text('Thank you! One more step - please click on the verification link')
  end
end

describe 'Advanced courses' do
  let(:page_object) { SchoolProfilesPage.new }
  before { visit '/california/alameda/1-Alameda-High-School/' }
  subject { page_object.advanced_courses }
  
  describe 'react' do
    before { visit '/california/alameda/1-Alameda-High-School/' }
    subject { page_object }
    its('advanced_courses_props') { is_expected.to include('rating', 'faq', 'sources', 'course_enrollments_and_ratings') }
    its('advanced_courses_props.rating') { is_expected.to eq(9) }
    its('advanced_courses_props.course_enrollments_and_ratings') { is_expected.to include('English', 'STEM', 'Social sciences', 'Foreign language', 'Arts', 'Health', 'Career / Technical') }
    its('advanced_courses_props.sources') { is_expected.to include('Advanced courses', 'GreatSchools Advanced Courses Rating') }
    its('advanced_courses_props.faq') { is_expected.to be_present }

    it 'react component loaded' do
      expect(page_object.wait_for_react_component("Courses").text).to be_present
    end
  end
end

describe 'General information' do
  before { visit '/california/alameda/1-Alameda-High-School/' }
  let(:page_object) { SchoolProfilesPage.new }
  subject { page_object.general_information }

  # TODO feels like this should actually be in a regular feature spec
  describe 'React' do
    subject { page_object.general_information_props }
    it { is_expected.to include(
      'config', 'has_non_osp_classes', 'has_osp_classes', 'is_claimed',
      'mailto_end', 'osp_link', 'qualaroo_module_link', 'sources'
    )}
    its('has_non_osp_classes') { is_expected.to be(true) }
    its('has_osp_classes') { is_expected.to be(true) }
    its('is_claimed') { is_expected.to be(false) }
    its('osp_link') { is_expected.to be_present }
    its('sources.length') { is_expected.to eq(1) }
    its('sources.first.heading') { is_expected.to eq('Classes') }
    its('sources.first.names.length') { is_expected.to eq(1) }
    its('sources.first.years.length') { is_expected.to eq(1) }
    it 'react component loaded' do
      expect(page_object.wait_for_react_component("OspSchoolInfo")).to be_present
    end
  end
end



describe 'Alameda High School' do
  let(:uri) { '/california/alameda/1-Alameda-High-School/' }
  before { visit uri }
  let(:page_object) { SchoolProfilesPage.new }
  subject { page_object }

  with_subject :hero do
    it { is_expected.to have_text('Unclaimed') }
    # Capybara seems to have trouble, maybe because of block elements inside
    # anchor tag? Or so much within data attributes? Not sure
    # its(:rating_text) { is_expected.to have_text('GreatSchools Rating') }
    # its(:rating_text) { is_expected.to_not have_text('GreatSchools Rating*') }
  end

  with_subject :test_scores do
    it { is_expected.to have_text("Test scores") }
  end

  with_subject :college_readiness do
    it { is_expected.to have_text('College readiness') }
  end

  with_subject :advanced_courses do
    it { is_expected.to have_text('Advanced courses') }
  end

  with_subject :equity_overview do
    it { is_expected.to have_text('Equity overview') }
  end

  with_subject :race_ethnicity do
    it { is_expected.to have_text('Race/ethnicity') }
  end

  with_subject :low_income_students do
    it { is_expected.to have_text('Low-income students') }
  end

  with_subject :students_with_disabilities do
    it { is_expected.to have_text('Students with disabilities') }
  end

  with_subject :general_information do
    it { is_expected.to have_text('General information') }
  end

  with_subject :students do
    it { is_expected.to have_text('Students') }
  end

  with_subject :teachers_and_staff do
    it { is_expected.to have_text('Teachers & staff') }
  end

  with_subject :review_form do
    it { is_expected.to have_text('How would you rate your experience at this school?') }
  end

  with_subject :review_list do
    its(:text) { is_expected.to be_present }
  end

  with_subject :homes_and_rentals do
    it { is_expected.to be_present }
  end

  with_subject :neighborhood do
    it { is_expected.to be_present }
    it { is_expected.to have_button('See this school\'s attendance zone') }
  end

  with_subject :nearby_schools do
    it { is_expected.to be_present }
    its('schools.size') { is_expected.to eq(3) }
  end
end

describe 'Bay Farm' do
  let(:uri) { '/california/alameda/2-Bay-Farm/' }
  before { visit uri }
  let(:page_object) { SchoolProfilesPage.new }
  subject { page_object }

  with_subject :hero do
    it { is_expected.to_not have_text('Unclaimed') }
    it { is_expected.to have_text('Claimed') }
  end

  with_subject :test_scores do
    it { is_expected.to have_text("Test scores") }
  end

  it { is_expected.to_not have_college_readiness }

  it { is_expected.to_not have_advanced_courses }
  with_subject :advanced_stem_courses do
    it { is_expected.to have_text('Advanced STEM courses') }
  end

  with_subject :equity_overview do
    it { is_expected.to have_text('Equity overview') }
  end

  with_subject :race_ethnicity do
    it { is_expected.to have_text('Race/ethnicity') }
  end

  with_subject :low_income_students do
    it { is_expected.to have_text('Low-income students') }
  end

  with_subject :students_with_disabilities do
    it { is_expected.to have_text('Students with disabilities') }
  end

  with_subject :general_information do
    it { is_expected.to have_text('General information') }
  end

  with_subject :students do
    it { is_expected.to have_text('Students') }
  end

  with_subject :teachers_and_staff do
    it { is_expected.to have_text('Teachers & staff') }
  end

  with_subject :review_form do
    it { is_expected.to have_text('How would you rate your experience at this school?') }
  end

  with_subject :review_list do
    its(:text) { is_expected.to be_present }
  end

  with_subject :homes_and_rentals do
    it { is_expected.to be_present }
  end

  with_subject :neighborhood do
    it { is_expected.to be_present }
    it { is_expected.to have_button('See this school\'s attendance zone') }
  end

  with_subject :nearby_schools do
    it { is_expected.to be_present }
    its('schools.size') { is_expected.to eq(3) }
  end
end

describe 'New York International School' do
  let(:uri) { '/new-york/new-york/18097-New-York-International-School/' }
  before { visit uri }
  let(:page_object) { SchoolProfilesPage.new }
  subject { page_object }

  with_subject :hero do
    it { is_expected.to_not have_text('Unclaimed') }
    it { is_expected.to have_text('Claimed') }
  end

  it { is_expected.to_not have_test_scores }
  it { is_expected.to_not have_college_readiness }
  it { is_expected.to_not have_advanced_courses }
  it { is_expected.to_not have_advanced_stem_courses }
  it { is_expected.to_not have_equity_overview }
  it { is_expected.to_not have_race_ethnicity }
  it { is_expected.to_not have_low_income_students }
  it { is_expected.to_not have_students_with_disabilities }

  with_subject :general_information do
    it { is_expected.to have_text('General information') }
  end

  with_subject :students do
    it { is_expected.to have_text('Students') }
  end

  it { is_expected.to_not have_teachers_and_staff }

  with_subject :review_form do
    it { is_expected.to have_text('How would you rate your experience at this school?') }
  end

  with_subject :review_list do
    its(:text) { is_expected.to be_present }
  end

  with_subject :homes_and_rentals do
    it { is_expected.to be_present }
  end

  with_subject :neighborhood do
    it { is_expected.to be_present }
    it { is_expected.to have_button('See this school\'s attendance zone') }
  end

  with_subject :nearby_schools do
    it { is_expected.to be_present }
    its('schools.size') { is_expected.to eq(3) }
  end
end

describe 'ME School Of Science & Mathematics' do
  let(:uri) { '/maine/limestone/5-Me-School-Of-Science--Mathematics/' }
  before { visit uri }
  let(:page_object) { SchoolProfilesPage.new }
  subject { page_object } 

  with_subject :hero do
    # Capybara seems to have trouble, maybe because of block elements inside
    # anchor tag? Or so much within data attributes? Not sure
    # its(:rating_text) { is_expected.to_not have_text('GreatSchools Rating') }
    # its(:rating_text) { is_expected.to have_text('GreatSchools Rating*') }
  end

  with_subject :test_scores do
    it { is_expected.to have_text("Test scores") }
  end

  with_subject :college_readiness do
    it { is_expected.to have_text('College readiness') }
  end

  it { is_expected.to_not have_advanced_courses }

  with_subject :advanced_stem_courses do
    it { is_expected.to have_text('Advanced STEM courses') }
  end

  it { is_expected.to_not have_equity_overview }

  with_subject :race_ethnicity do
    it { is_expected.to have_text('Race/ethnicity') }
  end

  with_subject :low_income_students do
    it { is_expected.to have_text('Low-income students') }
  end

  with_subject :students_with_disabilities do
    it { is_expected.to have_text('Students with disabilities') }
  end

  with_subject :general_information do
    it { is_expected.to have_text('General information') }
  end

  with_subject :students do
    it { is_expected.to have_text('Students') }
  end

  with_subject :teachers_and_staff do
    it { is_expected.to have_text('Teachers & staff') }
  end

  with_subject :review_form do
    it { is_expected.to have_text('How would you rate your experience at this school?') }
  end

  with_subject :review_list do
    its(:text) { is_expected.to be_present }
  end

  with_subject :homes_and_rentals do
    it { is_expected.to be_present }
  end

  with_subject :neighborhood do
    it { is_expected.to be_present }
    it { is_expected.to have_button('See this school\'s attendance zone') }
  end

  with_subject :nearby_schools do
    it { is_expected.to be_present }
    its('schools.size') { is_expected.to eq(0) }
    it { is_expected.to have_text('No schools found') }
  end
end

