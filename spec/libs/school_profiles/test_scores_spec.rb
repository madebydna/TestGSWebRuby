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
end

