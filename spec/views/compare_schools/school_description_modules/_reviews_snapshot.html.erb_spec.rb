require 'spec_helper'

describe 'compare_schools/school_description_modules/_reviews_snapshot.html.erb' do
  let(:reviews_snapshot) {{
      'avg_star_rating'=>4,
      'num_ratings'=>14,
      'num_reviews'=>17,
      'most_recent_reviews'=> [
          {'comments'=>
               'first comment',
           'posted'=>'2012-04-23',
           'who'=>'parent',
           'quality'=>'5'},
          {'comments'=>
               'second comment',
           'posted'=>'2011-07-11',
           'who'=>'parent',
           'quality'=>'5'}
      ],
      'star_counts'=>[0, 2, 0, 1, 0, 11]
  }}

  let(:school) { FactoryGirl.build(:an_elementary_school) }
  let(:decorated_school) { SchoolCompareDecorator.new(school) }
  let(:school_path) { 'www.greatschools.org/state/city/55-school/' }

  before do
    assign(:school, decorated_school)
    allow(view).to receive(:school_path) { school_path }
  end

  context 'when no snapshot is present' do
    before do
      allow_any_instance_of(SchoolCompareDecorator).to receive(:reviews_snapshot).and_return({})
      render
    end

    it 'displays no No community reviews' do
      expect(rendered).to have_content('No community reviews')
    end
  end

  context 'when snapshot is present' do
    before do
      allow_any_instance_of(SchoolCompareDecorator).to receive(:reviews_snapshot).and_return(reviews_snapshot)
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
end