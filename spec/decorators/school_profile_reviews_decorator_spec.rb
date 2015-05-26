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

  describe '#answer_summary_text' do
    let(:score_distribution) do
      {
        foo: 2,
        bar: 6,
        baz: 3
      }
    end
    before do
      allow(reviews).to receive(:score_distribution).and_return score_distribution
    end
    subject { reviews.answer_summary_text }

    it 'should use the value with the highest number of occurrences' do
      expect(subject).to match "bar"
    end

    it 'should display the number of occurrences' do
      expect(subject).to match "(#{6})"
    end

    context 'when there are no answers and therefore an empty score distribution' do
      let(:score_distribution) { [] }
      it { is_expected.to be_nil }
    end
  end

  describe '#see_all_reviews_phrase' do

    subject { reviews.see_comments_text }
    context 'when there are 10 reviews with comments' do
      let(:reviews) do
        FactoryGirl.build_list(:review, 10)
      end
      before do
        allow(reviews).to receive_message_chain(:having_comments, :count).
                              and_return 10
      end
      it { is_expected.to eq('See all 10 comments') }
    end
    context 'when there is 1 review with a comment' do
      let(:reviews) do
        FactoryGirl.build_list(:review, 1)
      end
      before do
        allow(reviews).to receive_message_chain(:having_comments, :count).
                              and_return 1
      end
      it { is_expected.to eq('See 1 comment') }
    end
    context 'when there are 10 reviews with no comments' do
      let(:reviews) do
        FactoryGirl.build_list(:review, 10, comment: '')
      end
      before do
        allow(reviews).to receive_message_chain(:having_comments, :count).
                              and_return 0
      end
      it { is_expected.to eq('See ratings') }
    end
    context 'when there is 5 reviews with comments 1 review without comments' do
      let(:reviews) do
        FactoryGirl.build_list(:review, 5)
        FactoryGirl.build(:review, comment: '')
      end
      before do
        allow(reviews).to receive_message_chain(:having_comments, :count).
                              and_return 5
      end
      it { is_expected.to eq('See all 5 comments') }
    end
  end

  describe '#see_all_reviews_phrase' do
    subject { reviews.see_all_reviews_phrase }
    context 'when there are 10 reviews' do
      let(:reviews) do
        FactoryGirl.build_list(:review, 10)
      end
      it { is_expected.to eq('See all 10 reviews')}
    end
    context 'when there is 1 review' do
      let(:reviews) do
        FactoryGirl.build_list(:review, 1)
      end
      it { is_expected.to eq('See 1 review')}
    end
  end
end