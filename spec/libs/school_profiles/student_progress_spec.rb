require 'spec_helper'

describe SchoolProfiles::StudentProgress do
  let(:school) { double('school', state: "AK") }
  let(:school_cache_data_reader) { double('school_cache_data_reader') }
  subject(:student_progress) do
    SchoolProfiles::StudentProgress.new(
        school,
        school_cache_data_reader: school_cache_data_reader
    )
  end

  it { is_expected.to respond_to(:rating) }
  it { is_expected.to respond_to(:info_text) }
  it { is_expected.to respond_to(:narration) }
  it { is_expected.to respond_to(:sources) }

  describe '#narration_key_from_rating' do
    def student_progress_narration_key(bucket)
      "lib.student_progress.narrative.#{bucket}_html"
    end

    {
        '1' => 1,
        '2' => 1,
        '3' => 2,
        '4' => 2,
        '5' => 3,
        '6' => 3,
        '7' => 4,
        '8' => 4,
        '9' => 5,
        '10' => 5
    }.each do |rating, bucket|
      describe "with a rating of #{rating}" do
        subject { student_progress.narration_key_from_rating }
        before { expect(school_cache_data_reader).to receive(:student_progress_rating).and_return(rating) }
        it { should eq student_progress_narration_key(bucket) }
      end
    end

    describe 'with a rating of NR' do
      subject { student_progress.narration_key_from_rating }
      before { expect(school_cache_data_reader).to receive(:student_progress_rating).and_return('NR') }
      it { should be_nil }
    end

    describe 'with a rating of nr' do
      subject { student_progress.narration_key_from_rating }
      before { expect(school_cache_data_reader).to receive(:student_progress_rating).and_return('nr') }
      it { should be_nil }
    end

    describe 'with a missing rating' do
      subject { student_progress.narration_key_from_rating }
      before { expect(school_cache_data_reader).to receive(:student_progress_rating).and_return(nil) }
      it { should be_nil }
    end
  end

  describe '#sources' do
    subject { student_progress.sources }
    let(:expected_description) { 'This sentence describes the Student Progress rating.' }
    let(:expected_methodology) { 'This sentence describes what data goes into the rating.' }

    before do
      allow(student_progress).to receive(:data_label).with(expected_description).and_return(expected_description)
      allow(student_progress).to receive(:data_label).with(expected_methodology).and_return(expected_methodology)
      expect(student_progress).to receive(:label).at_least(:once) { |arg| arg }
      expect(school).to receive(:state_name).and_return('California')
      expect(student_progress).to receive(:rating_year).and_return('2017')
    end

    describe 'Handles both description and methodology' do
      before do
        expect(student_progress).to receive(:rating_description).and_return(expected_description)
        expect(student_progress).to receive(:rating_methodology).and_return(expected_methodology)
      end

      it { should include expected_description }
      it { should include expected_methodology }
      it { should include 'California Dept of Education, 2017' }
    end

    describe 'Handles just description' do
      before do
        expect(student_progress).to receive(:rating_description).and_return(expected_description)
        expect(student_progress).to receive(:rating_methodology).and_return(nil)
      end

      it { should include expected_description }
      it { should_not include expected_methodology }
      it { should include 'California Dept of Education, 2017' }
    end

    describe 'Handles just methodology' do
      before do
        expect(student_progress).to receive(:rating_description).and_return(nil)
        expect(student_progress).to receive(:rating_methodology).and_return(expected_methodology)
      end

      it { should_not include expected_description }
      it { should include expected_methodology }
      it { should include 'California Dept of Education, 2017' }
    end

    describe 'Handles neither description nor methodology' do
      before do
        expect(student_progress).to receive(:rating_description).and_return(nil)
        expect(student_progress).to receive(:rating_methodology).and_return(nil)
      end

      it { should_not include expected_description }
      it { should_not include expected_methodology }
      it { should include 'California Dept of Education, 2017' }
    end
  end
end