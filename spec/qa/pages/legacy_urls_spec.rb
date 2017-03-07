require 'remote_spec_helper'

describe 'legacy URLs', type: :feature, remote: true, safe_for_prod: true do
  subject { page }

  describe 'old parentReview.page redirects correctly' do
    before { visit '/school/parentReview.page?topicId=1' }
    it { is_expected.to have_content 'Review your school!' }
  end

  describe 'old cities page /schools/cities/:state/:state_abbreviation' do
    context '/schools/cities/oklahoma/OK/' do
      before { visit '/schools/cities/oklahoma/OK/' }
      it { is_expected.to have_content 'Oklahoma School Information by City' }
    end
    context '/schools/cities/Washington_DC/DC/' do
      before { visit '/schools/cities/Washington_DC/DC/' }
      it { is_expected.to have_content 'Washington Dc School Information by City' }
    end
    context '/schools/cities/New_York/NY/' do
      before { visit '/schools/cities/New_York/NY/' }
      it { is_expected.to have_content 'New York School Information by City' }
    end
  end

  describe 'old districts page /schools/districts/:state/:state_abbreviation' do
    context '/schools/districts/Texas/TX' do
      before { visit '/schools/districts/Texas/TX' }
      it { is_expected.to have_content 'Texas School Districts' }
    end
    context '/schools/districts/Washington_DC/DC' do
      before { visit '/schools/districts/Washington_DC/DC' }
      it { is_expected.to have_content 'Washington Dc School Districts' }
    end
    context '/schools/districts/New_York/NY' do
      before { visit '/schools/districts/New_York/NY' }
      it { is_expected.to have_content 'New York School Districts' }
    end
  end


end
