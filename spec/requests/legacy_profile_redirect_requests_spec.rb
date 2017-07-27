require 'spec_helper'

def expect_redirect_to(path, status=301)
  expect(response.status).to eq(status)
  expect(response.headers['Location']).to eq("http://www.example.com#{path}")
end

describe 'Legacy profile redirect requests' do
  describe 'provided parameters mapping to a valid school' do
    before do
      FactoryGirl.create(:school, id: 1)
      get test_url
    end

    after do
      clean_models :ca, School
    end

    %w(
    /school/overview.page?id=1&state=ca
    /school/parentReviews.page?id=1&state=ca
    /school/rating.page?id=1&state=ca
    /school/mapSchool.page?id=1&state=ca
    /school/testScores.page?id=1&state=ca
    /school/teachersStudents.page?id=1&state=ca
    /school/research.page?id=1&state=ca
    /survey/form.page?id=1&state=ca
    /survey/results.page?id=1&state=ca
    /survey/start.page?id=1&state=ca
    /survey/startResults.page?id=1&state=ca
  ).each do |test_url|
      describe "provided #{test_url}" do
        let (:test_url) { test_url }

        it 'redirects to the correct profile URL' do
          expect_redirect_to '/california/alameda/1-Alameda-High-School/'
        end
      end
    end
  end

  describe 'provided parameters with valid state but invalid school' do
    before { get test_url }

    %w(
    /school/overview.page?id=0&state=ca
    /school/parentReviews.page?id=0&state=ca
    /school/rating.page?id=0&state=ca
    /school/mapSchool.page?id=0&state=ca
    /school/testScores.page?id=0&state=ca
    /school/teachersStudents.page?id=0&state=ca
    /school/research.page?state=ca
    /survey/form.page?id=0&state=ca
    /survey/results.page?id=0&state=ca
    /survey/start.page?id=0&state=ca
    /survey/startResults.page?id=0&state=ca
  ).each do |test_url|
      describe "provided #{test_url}" do
        let (:test_url) { test_url }

        it 'redirects to the correct state home URL' do
          expect_redirect_to '/california/', 302
        end
      end
    end
  end

  describe 'provided invalid parameters' do
    before { get test_url }

    %w(
    /school/overview.page?id=0&state=aa
    /school/parentReviews.page?id=one&state=bay-area
    /school/rating.page?id=&state=one+two%20three
    /school/mapSchool.page?id=1
    /school/testScores.page?state=aa
    /school/teachersStudents.page
    /school/research.page
    /survey/form.page
    /survey/results.page
    /survey/start.page
    /survey/startResults.page
  ).each do |test_url|
      describe "provided #{test_url}" do
        let (:test_url) { test_url }

        it 'redirects to the homepage' do
          expect_redirect_to '/', 302
        end
      end
    end
  end
end