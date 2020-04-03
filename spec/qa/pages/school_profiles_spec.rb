require 'features/page_objects/school_profiles_page'
require 'features/page_objects/account_page'

describe 'School profiles page', remote: true do
  describe 'preschool profile', type: :feature, safe_for_prod: true do
    before { visit '/new-jersey/newark/preschools/Broadway-Mini-Mall-Head-Start/7453/' }
    it 'should show school name' do
      expect(page.find('h1')).to have_text('Broadway Mini Mall Head Start')
    end
  end

  describe 'I can view profiles for schools in states or cities with hyphenated names', type: :feature, remote: true, safe_for_prod: true do
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

  describe 'follow a school while registering', type: :feature do
    let(:account_page) { AccountPage.new }

    it 'when I save the school the right newsletters are saved and it is added to my school list' do
      skip "Due to intermittent failures"
      visit('/california/alameda/1-Alameda-High-School/')
      first('.js-followThisSchool').click
      register_in_email_modal
      sleep 2
      expect(page).to have_text('All set! You are signed up for our newsletter and updates on Alameda High School')
      sleep 10

      confirm_school_signup
    end

    # TODO: Find better solution to injecting sleep directives
    it 'when I click the newsletter link in the footer the right newsletters are saved and it is added to my school list' do
      skip "Can't seem to get this test to work"
      visit('/california/alameda/1-Alameda-High-School/')
      within('footer') do
        click_link 'Newsletter'
      end
      sleep 10
      register_in_modal
      sleep 5
      expect(page).to have_text("Success!\nYou've signed up to receive updates")
      confirm_school_signup
    end

    def confirm_school_signup
      account_page.load
      account_page.email_subscriptions.closed_arrow.click
      expect(account_page.email_subscriptions.mystat_checkbox).to be_checked
      expect(account_page.email_subscriptions.greatnews_checkbox).to be_checked
      expect(account_page.email_subscriptions.sponsor_checkbox).to be_checked
      expect(account_page.email_subscriptions).to have_text('Alameda High School, Alameda, CA')
    end
  end

  describe 'Advanced courses' do
    let(:page_object) { SchoolProfilesPage.new }

    before do
      page_object.load(state: 'california', city: 'alameda', school_id_and_name: '1-Alameda-High-School')
      page_object.wait_until_advanced_stem_courses_visible
    end

    subject do
      page_object.advanced_stem_courses
    end

    its('title') { is_expected.to have_text('Advanced & STEM courses') }
    its('score_items.length') { is_expected.to eq(3) }
    its('source_link') { is_expected.to be_present }
    it 'should list sources when clicking source link' do
      skip "due to intermittent failures"
      subject.wait_until_source_link_visible
      subject.source_link.click
      expect(find('.remodal', wait: 3)).to have_text('GreatSchools profile data sources & information')
    end
  end

  describe 'General information' do
    let(:page_object) { SchoolProfilesPage.new }

    before do
      page_object.load(state: 'california', city: 'alameda', school_id_and_name: '1-Alameda-High-School')
      page_object.wait_until_general_information_visible
    end

    subject { page_object.general_information }

    its('title') { is_expected.to have_text('General information') }
    it { is_expected.to have_text('Here you can learn about this school’s hours, enrollment, sports, classes and more.') }

    it 'should have a link to the OSP page' do
      skip "due to intermittent failures"
      subject.wait_until_edit_link_visible
      osp_page = subject.go_to_osp_page
      expect(osp_page).to be_displayed
      expect(osp_page).to have_text('Claim your school profile')
    end
  end

  describe 'Alameda High School' do
    let(:page_object) { SchoolProfilesPage.new }

    before do
      page_object.load(state: 'california', city: 'alameda', school_id_and_name: '1-Alameda-High-School')
      page_object.wait_until_neighborhood_visible
    end

    subject { page_object }

    with_subject :hero do
      it { is_expected.to have_text('Unclaimed') }
    end

    with_subject :test_scores do
      it { is_expected.to have_text("Test scores") }
    end

    with_subject :college_readiness do
      it { is_expected.to have_text('College readiness') }
    end

    with_subject :advanced_stem_courses do
      it { is_expected.to have_text('Advanced & STEM courses') }
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

    with_subject :student_diversity do
      it { is_expected.to have_text('Student demographics') }
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
      its('title_bar') do
        pending("Can't seem to find homes_and_rentals section")
        is_expected.to have_text('Homes for sale near Alameda High School')
      end
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

  describe 'Bay Farm - a claimed school' do
    let(:page_object) { SchoolProfilesPage.new }

    before do
      page_object.load(state: 'california', city: 'alameda', school_id_and_name: '2-Bay-Farm')
      page_object.wait_until_neighborhood_visible
    end

    subject { page_object }

    with_subject :hero do
      it { is_expected.to_not have_text('Unclaimed') }
      it { is_expected.to have_text('Claimed') }
    end

    with_subject :test_scores do
      it { is_expected.to have_text("Test scores") }
    end

    it { is_expected.to have_no_college_readiness }

    it { is_expected.to have_no_advanced_courses }

    with_subject :general_information do
      it { is_expected.to have_text('General information') }
      its('tabs.length') { is_expected.to eq(5) }
      it 'should have correct tab names' do
        expect(subject.tab_names).to include('Overview')
        expect(subject.tab_names).to include('Calendar')
        expect(subject.tab_names).to include('Enrollment')
        expect(subject.tab_names).to include('Classes')
        expect(subject.tab_names).to include('Sports & clubs')
      end
    end
  end

  describe 'New York International School - a private school' do
    let(:page_object) { SchoolProfilesPage.new }

    before do
      page_object.load(state: 'new-york', city: 'new-york', school_id_and_name: '18097-New-York-International-School')
      page_object.wait_until_neighborhood_visible
    end

    subject { page_object }

    with_subject :hero do
      it { is_expected.to_not have_text('Unclaimed') }
      it { is_expected.to have_text('Claimed') }
    end

    it { is_expected.to have_no_test_scores }
    it { is_expected.to have_no_college_readiness }
    it { is_expected.to have_no_advanced_courses }
    it { is_expected.to have_no_advanced_stem_courses }
    it { is_expected.to have_no_equity_overview }
    it { is_expected.to have_no_race_ethnicity }
    it { is_expected.to have_no_low_income_students }
    it { is_expected.to have_no_students_with_disabilities }
    it { is_expected.to have_no_teachers_and_staff }

    with_subject :general_information do
      it { is_expected.to have_text('General information') }
    end

    it "should have an empty student demographics module" do
      within('#Students-empty') do
        expect(page).to have_text "Currently, this information is unavailable"
      end
    end

    with_subject :review_form do
      it { is_expected.to have_text('How would you rate your experience at this school?') }
    end

    with_subject :review_list do
      its(:text) { is_expected.to be_present }
    end

    with_subject :homes_and_rentals do
      it { pending("Can't seem to find homes_and_rentals section"); is_expected.to be_present }
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
    let(:page_object) { SchoolProfilesPage.new }

    before do
      page_object.load(state: 'maine', city: 'limestone', school_id_and_name: '5-Me-School-Of-Science--Mathematics')
      page_object.wait_until_neighborhood_visible
    end

    subject { page_object }

    with_subject :hero do
      it { is_expected.to have_text('Unclaimed') }
      its('rating_text') { is_expected.to have_text("GREATSCHOOLS RATING*") }
      its('rating') { is_expected.to have_text("9") }
    end

    with_subject :test_scores do
      it { is_expected.to have_text("Test scores") }
    end

    with_subject :college_readiness do
      it { is_expected.to have_text('College readiness') }
    end

    it { is_expected.to have_no_advanced_courses }

    with_subject :advanced_stem_courses do
      it { is_expected.to have_text('Advanced & STEM courses') }
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

    with_subject :student_diversity do
      it { is_expected.to have_text('Student demographics') }
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
      it { pending("Can't seem to find homes_and_rentals section"); is_expected.to be_present }
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
end
