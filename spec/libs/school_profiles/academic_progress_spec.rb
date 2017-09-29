require "spec_helper"

describe SchoolProfiles::AcademicProgress do
  let(:school) { double("school") }
  let(:school_cache_data_reader) { double("school_cache_data_reader") }
  subject(:academic_progress) do
    SchoolProfiles::AcademicProgress.new(
        school,
        school_cache_data_reader: school_cache_data_reader

    )
  end

  # it { is_expected.to respond_to(:narration_text_segment_by_test_score) }
  it { is_expected.to respond_to(:test_scores_rating) }
  it { is_expected.to respond_to(:academic_progress_rating) }

  describe 'narration_text_segment_by_test_score ' do

    it '0 0 returns blank ' do
      allow(subject).to receive(:test_scores_rating).and_return(0)
      allow(subject).to receive(:academic_progress_rating).and_return(0)
      expect(subject.narration_text_segment_by_test_score).to eq('')
    end

    it '2 7 returns a string ' do
      allow(subject).to receive(:test_scores_rating).and_return(2)
      allow(subject).to receive(:academic_progress_rating).and_return(7)
      expect(subject.narration_text_segment_by_test_score).to be_present
    end

    it 'nil 7 returns blank ' do
      allow(subject).to receive(:test_scores_rating).and_return(nil)
      allow(subject).to receive(:academic_progress_rating).and_return(7)
      expect(subject.narration_text_segment_by_test_score).to eq('')
    end

    it '3 nil returns blank ' do
      allow(subject).to receive(:test_scores_rating).and_return(3)
      allow(subject).to receive(:academic_progress_rating).and_return(nil)
      expect(subject.narration_text_segment_by_test_score).to eq('')
    end

    it '5 6 returns blank ' do
      allow(subject).to receive(:test_scores_rating).and_return(5)
      allow(subject).to receive(:academic_progress_rating).and_return(6)
      expect(subject.narration_text_segment_by_test_score).to eq('')
    end

    it '8 6 returns a string ' do
      allow(subject).to receive(:test_scores_rating).and_return(8)
      allow(subject).to receive(:academic_progress_rating).and_return(6)
      expect(subject.narration_text_segment_by_test_score).to be_present
    end
  end

  describe 'rating_by_quintile(ap_rating)' do
    subject { academic_progress.rating_by_quintile(academic_progress_rating) }
    {
        0 => nil,
        1 => 1,
        2 => 1,
        3 => 2,
        4 => 2,
        5 => 3,
        6 => 3,
        7 => 4,
        8 => 4,
        9 => 5,
        10 => 5,
        11 => nil,
        nil => nil
    }.each do |(input_rating, expected_level)|
      context "With a academic progress rating of #{input_rating}" do
        let (:academic_progress_rating) { input_rating }
        it { is_expected.to eq(expected_level) }
      end
    end
  end

  describe 'narration_level(rating)' do
    subject { academic_progress.narration_level(test_score_rating) }
    {
        0 => nil,
        1 => 'low',
        4 => 'low',
        5 => nil,
        6 => nil,
        7 => 'high',
        10 => 'high',
        11 => nil,
        nil => nil
    }.each do |(input_rating, expected_level)|
      context "With a test score rating of #{input_rating}" do
        let (:test_score_rating) { input_rating }
        it { is_expected.to eq(expected_level) }
      end
    end
  end

end