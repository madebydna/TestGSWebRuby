require 'spec_helper'

describe SchoolProfiles::RatingScoreItem do
  subject(:rating_score_item) do
    SchoolProfiles::RatingScoreItem.new
  end
  it { is_expected.to respond_to(:score) }
  it { is_expected.to respond_to(:state_average) }
  it { is_expected.to respond_to(:visualization) }

  describe '#score_rating' do
    subject { rating_score_item.score_rating }
    {
        -1 => 1,
        0 => 1,
        9 => 1,
        9.99 => 1,
        10 => 2,
        19.9 => 2,
        90 => 10,
        100 => 10,
        101 => 10
    }.each do |score, rating|
      describe "with a score of #{score}" do
        before { rating_score_item.score = score }

        it { is_expected.to eq(rating) }
      end
    end
  end
end
