require 'spec_helper'
require 'features/page_objects/school_profiles_page'

RSpec::Matchers.define :have_gs_rating_of do |expected_rating|
  match do |actual|
    actual.gs_rating.text == expected_rating.to_s
  end
  failure_message do |actual|
    "expected a GS rating of #{expected} but got #{actual.gs_rating.text}"
  end
end

describe 'Visitor' do
  after do
    clean_dbs(:gs_schooldb)
    clean_models(:ca, School)
  end

  scenario 'views new school profile with valid school' do
    school = create(:school_with_new_profile)

    visit school_path(school)

    expect(page).to have_content(school.name)
  end

  scenario 'views new school profile invalid school' do
    school = build(:school_with_new_profile)
    stub_request(:post, /\/solr\/main\/select/).to_return(status: 200, body: "{}", headers: {})
    visit school_path(school)
    uri = URI.parse(current_url)
    expect(uri.path).to eq state_path('california')
  end

  scenario 'sees the school\'s GreatSchools rating' do
    school = create(:school_with_new_profile, name: 'Foo bar school')
    rating = create(:cached_gs_rating, state: 'ca', school_id: school.id)

    visit school_path(school)

    page_object = SchoolProfilesPage.new
    expect(page_object).to have_gs_rating
    expect(page_object).to have_gs_rating_of('5/10')
  end

  scenario 'sees school address info' do
    school = create(:school_with_new_profile,
      name: 'Foo bar school',
      street: '123 yellow brick road',
      city: 'Atlantis',
      state: 'ca',
      zipcode: '99999'
    )

    visit school_path(school)

    expect(page).to have_content(school.street)
    expect(page).to have_content(school.city)
    expect(page).to have_content(school.zipcode)
  end

  scenario 'sees the school\'s type' do
    school = create(:school_with_new_profile, type: 'charter')
    visit school_path(school)
    expect(page).to have_content('charter')
  end

  scenario 'sees the school\'s district name' do
    district = create(:alameda_city_unified_district_record)
    school = create(:school_with_new_profile, district_id: district.district_id)
    visit school_path(school)
    expect(page).to have_content(district.name)
  end

  scenario 'sees the school\'s phone number' do
    school = create(:school_with_new_profile, phone: '123-555-1234')
    visit school_path(school)
    expect(page).to have_content(school.phone)
  end

  scenario 'sees a link to the school\'s website' do
    school = create(:school_with_new_profile, home_page_url: 'http://www.google.com')
    visit school_path(school)
    expect(SchoolProfilesPage.new).to have_link('School website',
      href: school.home_page_url
    )
  end

  context 'when the school has more than one grade' do
    let!(:school) { create(:school_with_new_profile, level: '4,5,6') }
    scenario 'sees the school\'s grade range' do
      visit school_path(school)
      expect(page).to have_content('Grades')
      expect(page).to have_content('4-6')
    end
  end

  context 'when the school has only one grade' do
    let!(:school) { create(:school_with_new_profile, level: '6') }
    scenario 'sees the school\'s grade range' do
      visit school_path(school)
      expect(page).to have_content('Grade')
      expect(page).to_not have_content('Grades')
      expect(page).to have_content('6')
    end
  end

  scenario 'sees how many students are at the school' do
    school = create(:school_with_new_profile)
    create(:cached_enrollment, state: 'ca', school_id: school.id)
    visit school_path(school)
    expect(page).to have_content('1,200')
    expect(page).to_not have_content('1200.0')
    expect(page).to_not have_content('1,200.0')
  end

  scenario 'sees the number of all reviews and the average 5-star rating' do
    school = create(:school_with_new_profile)
    create(:cached_reviews_info, state: 'ca', school_id: school.id)
    visit school_path(school)
    page_object = SchoolProfilesPage.new
    expect(page_object).to have_content('348381') # reviews among all topics
    expect(page_object).to have_star_rating_of(4)
  end

  describe 'structured markup' do
    scenario 'school schema' do
      school = create(
        :school_with_new_profile,
        name: 'Alameda High School',
        street: '123 main st',
        city: 'Alameda',
        state: 'CA',
        zipcode: '12345',
        home_page_url: 'http://www.foo.bar'
      )

      expected_markup = {
        "@context" => "https://schema.org",
        "@type" => "School",
        "name" => "Alameda High School",
        "description" => "Alameda High School is a public school. This school does not qualify for a GreatSchools rating because there is not sufficient academic data to generate one.",
        "address" => {
          "@type" => "PostalAddress",
          "streetAddress" => "123 main st",
          "addressLocality" => "Alameda",
          "addressRegion" => "CA",
          "postalCode" => "12345"
        },
        "sameAs" => [
          "http://www.foo.bar"
        ]
      }.to_json[1..-2]

      visit school_path(school)
      scripts = all('script', visible: false).select do |s|
        s[:type] == 'application/ld+json'
      end
      expect(scripts).to_not be_blank
      script = scripts.find { |s| s.native.text.include?('"@type":"School"') }
      expect(script).to_not be_nil
      expect(script.native.text).to include(expected_markup)
    end

    describe 'aggregateRating schema' do
      scenario 'with 3 five star reviews' do
        school = create(:school_with_new_profile)
        [1,2,3].map do |n|
          create(:five_star_review, answer_value: n, school_id: school.id, state: school.state)
        end

        expected_markup = {
          "@type" => "AggregateRating",
          "ratingValue" => 2,
          "bestRating" => 5,
          "worstRating" => 1,
          "reviewCount" => 3,
          "ratingCount" => 3 
        }.to_json

        visit school_path(school)
        scripts = all('script', visible: false).select do |s|
          s[:type] == 'application/ld+json'
        end
        expect(scripts).to_not be_blank
        script = scripts.find do |s|
          s.native.text.include?(expected_markup)
        end
        expect(script).to_not be_nil
      end

      scenario 'with 3 five star reviews and 2 other reviews' do
        school = create(:school_with_new_profile)
        [1,2,3].map do |n|
          create(:five_star_review, answer_value: n, school_id: school.id, state: school.state, comment: ('foo ' * 15))
        end
        [1,2].map do |n|
          create(:teacher_effectiveness_review, school_id: school.id, state: school.state, comment: ('foo ' * 15) )
        end

        expected_markup = {
          "@type" => "AggregateRating",
          "ratingValue" => 2,
          "bestRating" => 5,
          "worstRating" => 1,
          "reviewCount" => 5,
          "ratingCount" => 3 
        }.to_json

        visit school_path(school)
        scripts = all('script', visible: false).select do |s|
          s[:type] == 'application/ld+json'
        end
        expect(scripts).to_not be_blank
        script = scripts.find do |s|
          s.native.text.include?(expected_markup)
        end
        expect(script).to_not be_nil
      end

      scenario 'with 0 five star reviews and 2 other reviews' do
        school = create(:school_with_new_profile)
        [1,2].map do |n|
          create(:teacher_effectiveness_review, school_id: school.id, state: school.state, comment: ('foo ' * 15) )
        end

        visit school_path(school)
        scripts = all('script', visible: false).select do |s|
          s[:type] == 'application/ld+json'
        end

        scripts.each do |s|
          expect(s.native.text).to_not have_text('AggregateRating')
        end
      end
    end

  end

end
