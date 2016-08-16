require "spec_helper"

describe SchoolProfiles::TestScores do
  let(:school) { double("school") }
  let(:school_cache_data_reader) { double("school_cache_data_reader") }
  subject(:hero) do
    SchoolProfiles::TestScores.new(
      school,
      school_cache_data_reader: school_cache_data_reader
    )
  end
  it { is_expected.to respond_to(:rating) }
  it { is_expected.to respond_to(:subject_scores) }

  describe "::RatingLabelMap" do
    it "should have 10 items" do
      expect(SchoolProfiles::TestScores::RatingLabelMap.count).to eq(10)
    end
  end

  describe "#rating_label" do
    SchoolProfiles::TestScores::RatingLabelMap
      .each do |rating, label|
      it "returns correct #{label} for rating score: #{rating}" do
        allow(subject).to receive(:rating).and_return(rating.to_i)
        expect(subject.rating_label).to eq(SchoolProfiles::TestScores::RatingLabelMap[rating])
      end
    end
  end
end
