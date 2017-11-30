require 'spec_helper'

describe SchoolProfiles::RatingScoreItem do
  subject(:rating_score_item) do
    SchoolProfiles::RatingScoreItem.new
  end
  it { is_expected.to respond_to(:score) }
  it { is_expected.to respond_to(:state_average) }
  it { is_expected.to respond_to(:visualization) }
end
