require 'spec_helper'

describe SchoolProfiles::Toc do
  ##will want to make a school that is missing some data
  let(:school) { double('school') }
  let(:school_cache_data_reader) { double('school_cache_data_reader') }
  let(:test_scores) {double('test_scores')}
  let(:college_readiness) {double('college_readiness')}
  let(:equity) {double('equity')}
  let(:students) {double('students')}
  subject(:toc) do
    SchoolProfiles::Toc.new(test_scores, college_readiness, equity, students)
  end
  it { is_expected.to respond_to(:content) }
end