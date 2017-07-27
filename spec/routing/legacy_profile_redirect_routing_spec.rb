require 'spec_helper'

describe 'Legacy school profile URL routing' do
  subject { get test_url }

  %w(
    /school/overview.page?id=1&state=ca
    /school/parentReviews.page?id=1&state=ca
    /school/rating.page?id=1&state=ca
    /school/mapSchool.page?id=1&state=ca
    /school/testScores.page?id=1&state=ca
    /school/teachersStudents.page?id=1&state=ca
  ).each do |test_url|
    describe "provided #{test_url}" do
      let (:test_url) { test_url }
      it { is_expected.to route_to(controller: 'legacy_profile_redirect', action: 'show', id: '1', state: 'ca') }
    end
  end
end