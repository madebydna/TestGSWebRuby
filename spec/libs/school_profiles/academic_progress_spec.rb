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

  it { is_expected.to respond_to(:narration_text_segment_by_test_score) }
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

  describe 'narration_level(rating)' do
    it '0 returns nil ' do
      expect(subject.narration_level(0)).to eq(nil)
    end

    it '1 returns low ' do
      expect(subject.narration_level(1)).to eq('low')
    end

    it '4 returns low ' do
      expect(subject.narration_level(4)).to eq('low')
    end

    it '10 returns high ' do
      expect(subject.narration_level(10)).to eq('high')
    end

    it '7 returns high ' do
      expect(subject.narration_level(7)).to eq('high')
    end

    it '6 returns nil ' do
      expect(subject.narration_level(6)).to eq(nil)
    end

    it 'nil returns nil ' do
      expect(subject.narration_level(nil)).to eq(nil)
    end
  end

  describe 'rating_by_quintile(ap_rating)' do
    it '0 returns nil ' do
      expect(subject.rating_by_quintile(0)).to eq(nil)
    end

    it '1 returns low ' do
      expect(subject.rating_by_quintile(1)).to eq(1)
    end

    it '4 returns low ' do
      expect(subject.rating_by_quintile(4)).to eq(2)
    end

    it '10 returns high ' do
      expect(subject.rating_by_quintile(10)).to eq(5)
    end

    it '7 returns high ' do
      expect(subject.rating_by_quintile(7)).to eq(4)
    end

    it '6 returns nil ' do
      expect(subject.rating_by_quintile(6)).to eq(3)
    end

    it 'nil returns nil ' do
      expect(subject.rating_by_quintile(nil)).to eq(nil)
    end
    it '1000 returns nil ' do
      expect(subject.rating_by_quintile(1000)).to eq(nil)
    end
  end

end