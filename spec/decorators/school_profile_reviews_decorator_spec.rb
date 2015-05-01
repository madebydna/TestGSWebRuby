require 'spec_helper'

# Use type of :view so that I get a view context I can give to the decorator
describe SchoolProfileReviewsDecorator, type: :view do
  let(:reviews) do
    FactoryGirl.build_list(:review, 2)
  end
  before do
    SchoolProfileReviewsDecorator.decorate(reviews, view)
  end
  subject { reviews }

  describe '#to_bar_chart_array' do
    before do
      allow(reviews).to receive(:five_star_rating_score_distribution) do
        {
          '1' => 1,
          '3' => 1,
          '2' => 1,
          '5' => 1,
          '4' => 1
        }
      end
    end
    subject { reviews.to_bar_chart_array }
    it 'should order stars in descending order' do
      chart_keys = subject.map(&:first)
      expect(chart_keys).to eq(['Stars', '5 stars', '4 stars', '3 stars', '2 stars', '1 star'])
    end
  end
end