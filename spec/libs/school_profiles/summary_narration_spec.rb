require 'spec_helper'

describe SchoolProfiles::SummaryNarration do
  let(:summary_rating) { double('SummaryRating') }
  let(:school) { double('school') }
  let(:school_cache_data_reader) { double('school_cache_data_reader') }
  subject(:summary_narration) { SchoolProfiles::SummaryNarration.new(summary_rating, school, school_cache_data_reader: school_cache_data_reader) }

  describe '#test_scores_only_after_more' do
    subject { summary_narration.test_scores_only_after_more }
    before { allow(school).to receive(:state).and_return('nj') }
    it { is_expected.to_not be_empty }
  end

  describe '#test_scores_only_before_more' do
    subject { summary_narration.test_scores_only_before_more }
    before { allow(school_cache_data_reader).to receive(:gs_rating).and_return(5) }
    it { is_expected.to_not be_empty }
  end

  describe '#build_content_test_score_only' do
    subject { summary_narration.build_content_test_score_only }
    let(:before_fragment) { 'Sentence fragment before more' }
    let(:after_fragment) { 'sentence fragment after more' }
    before do
      allow(school_cache_data_reader).to receive(:gs_rating).and_return(5)
      expect(summary_narration).to receive(:test_scores_only_before_more).and_return(before_fragment)
      expect(summary_narration).to receive(:test_scores_only_after_more).and_return(after_fragment)
    end

    it 'Should return two fragments' do
      expect(subject).to eq([before_fragment, after_fragment])
    end
  end
end
