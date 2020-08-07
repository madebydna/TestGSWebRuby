require 'spec_helper'

describe SchoolProfiles::SummaryNarration do  
  let(:summary_rating) do
    double('SummaryRating',
      test_scores: { rating: 9, title: 'Test Scores' },
      student_progress: { rating: 4, title: 'Student Progress' },
      equity_overview: { rating: 7, title: 'Equity Overview' },
      college_readiness: { rating: 2, title: 'College Readiness' }
    )
  end
  let(:school) { double('school', state: "CA") }
  let(:school_cache_data_reader) do
    double('school_cache_data_reader', 
      school: school,
      gs_rating: 10,
      attendance_flag?: true,
      discipline_flag?: true
    )
  end
  subject(:summary_narration) { SchoolProfiles::SummaryNarration.new(summary_rating, school, school_cache_data_reader: school_cache_data_reader) }

  describe '#build_content' do
    let(:content_array) { subject.build_content }

    context 'with all possible ratings available' do
      it 'has summary rating as the first narration element' do
        expect(content_array[0]).to match(/school quality/)
      end

      it 'has student progress as the second narration element' do
        expect(content_array[1]).to match(/Student_progress/)
      end

      it 'has college readiness as the third narration element' do
        expect(content_array[2]).to match(/College_readiness/)
      end

      it 'has equity rating as the fourth narration element' do
        expect(content_array[3]).to match(/Equity_overview/)
      end

      it 'has test scores as the fifth narration element' do
        expect(content_array[4]).to match(/Test_scores/)
      end

      it 'has discipline and attendance as the sixth narration element' do
        expect(content_array[5]).to match(/Discipline_and_attendance/)
      end
    end

    context 'with some ratings missing' do
      before do
        allow(summary_rating).to receive(:test_scores).and_return({})
        allow(summary_rating).to receive(:college_readiness).and_return({})
        allow(school_cache_data_reader).to receive(:attendance_flag?).and_return(false)
        allow(school_cache_data_reader).to receive(:discipline_flag?).and_return(false)
      end

      it 'maintains the defined order of narration elements' do
        expect(content_array.join('')).to match(/^.+school quality.+#Student_progress.+#Equity_overview.+more information.+$/m)
      end
    end
  end

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
