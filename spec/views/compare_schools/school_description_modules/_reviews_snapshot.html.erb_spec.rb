require 'spec_helper'
require_relative '../../../helpers/school_with_cache_helper'

describe 'compare_schools/school_description_modules/_reviews_snapshot.html.erb' do
  let(:reviews_snapshot) {{
      'avg_star_rating'=>4,
      'num_ratings'=>14,
      'num_reviews'=>17
  }}
  let(:no_ratings_snapshot) {{
      'avg_star_rating'=>nil,
      'num_ratings'=>0,
      'num_reviews'=>17
  }}

  init_school_with_cache

  let(:decorated_school) { SchoolCompareDecorator.new(school_with_cache) }
  let(:school_path) { 'www.greatschools.org/state/city/55-school/' }

  before do
    assign(:school, decorated_school)
    allow(view).to receive(:school_path) { school_path }
  end

  context 'when no snapshot is present' do
    before do
      allow(decorated_school.school_cache).to receive(:reviews_snapshot).and_return({})
      render
    end

    it 'displays no No community reviews' do
      expect(rendered).to have_content('No community reviews')
    end
  end

  context 'when snapshot is present' do
    before do
      allow(decorated_school.school_cache).to receive(:reviews_snapshot).and_return(reviews_snapshot)
      render
    end

    it 'displays the correct number of stars' do
      expect(rendered).to have_selector('span.iconx24-stars.i-24-orange-star.i-24-star-4')
    end

    it 'displays the correct text' do
      expect(rendered).to have_selector('div', text: '4 stars')
      expect(rendered).to have_selector('div', text: 'Based on 14 ratings')
      expect(rendered).to have_link('17 reviews', href: "#{school_path}reviews/")
    end
  end

  context 'when there are no ratings' do
    before do
      allow(decorated_school.school_cache).to receive(:reviews_snapshot).and_return(no_ratings_snapshot)
      render
    end

    it 'does not display the stars' do
      expect(rendered).to_not have_selector('span.iconx24-stars')
    end

    it 'displays No community ratings' do
      expect(rendered).to have_content('No community ratings')
    end

    it 'shows the number of reviews' do
      expect(rendered).to have_link('17 reviews', href: "#{school_path}reviews/")
    end
  end
end