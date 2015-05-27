require 'spec_helper'

describe ReviewTopic do
  let(:review_topic) { FactoryGirl.build(:review_topic) }
  let (:school) { FactoryGirl.build(:school) }
  after do
    clean_dbs :gs_schooldb
  end
  after(:each) do
    clean_models :ca, School, TestDataSet, TestDataSchoolValue
  end

  it { is_expected.to be_a(ReviewTopic)}

  it 'should have a combination of attributes that are valid' do
    expect(review_topic).to be_valid
  end

  describe '#level_code_array' do
    it 'should return an array' do
      expect(subject.level_code_array).to be_a(Array)
    end

    it 'should return an array of the level codes' do
      expect(review_topic.level_code_array).to eq(%w(p e m h))
    end
  end

    describe '#build_questions_display_array' do
    it 'should return array when given a school' do
      expect(subject.build_questions_display_array(:school)).to be_a(Array)
    end
  end

  describe '#create_review_topics_for_school' do
    it 'should return instance of ReviewTopic::ReviewTopicsForSchool class with a school' do
      expect(subject.create_review_topics_for_school(:school)).to be_a(ReviewTopic::ReviewTopicsForSchool)
    end
  end

describe '.find_by_school' do
    let(:alameda_high_school) {FactoryGirl.build(:alameda_high_school) }
    let!(:review_topic_matching) {FactoryGirl.create(:review_topic, school_level: alameda_high_school.level_code, school_type: alameda_high_school.type)}
    let!(:review_topic_not_matching) {FactoryGirl.create(:review_topic, school_level: 'e', school_type: alameda_high_school.type)}
    let!(:review_topic_not_matching2) {FactoryGirl.create(:review_topic, school_level: alameda_high_school.level_code, school_type: 'private')}

    it 'should return Topic matching level code of school and type of school' do
      expect(ReviewTopic.find_by_school(alameda_high_school)).to include(review_topic_matching)
    end

    it 'should not return Topic that is not matching level code of school but matches school type' do
      expect(ReviewTopic.find_by_school(alameda_high_school)).to_not include(review_topic_not_matching)
    end
    #
    it 'should not return Topic not matching type of school but matching school level' do
      expect(ReviewTopic.find_by_school(alameda_high_school)).to_not include(review_topic_not_matching2)
    end
  end

  describe 'ReviewTopic::ReviewTopicsForSchool' do

    subject { ReviewTopic::ReviewTopicsForSchool.new(review_topic, school) }
    describe '#initialize' do
      it 'sets review_topic' do
        expect(subject.review_topic).to eq(review_topic)
      end
      it 'sets school' do
        expect(subject.school).to eq(school)
      end
    end

    describe '#questions' do
      it 'should return questions that match school' do
        mocked_review_questions = (1..4).map do |i|
          truthiness = true if i % 2 == 0
          double(matches_school?: truthiness)
        end
        allow(subject.review_topic).to receive(:review_questions).and_return(mocked_review_questions)
        expect(subject.questions.count).to eq(2)
      end
    end
    describe '#display_array' do
      it 'should return array of hashes' do
        pending ('removed test because the api is using review_questions and not an array of display hashes; Remove if new design is confirmed;')
        expect(subject.display_array).to be_a(Array)
      end
    end
  end

  describe '#overall?' do
    context 'when its a overall topic' do
      let(:review_topic) { FactoryGirl.create(:overall_topic) }
      subject { review_topic.overall? }
      it { is_expected.to eq(true) }
    end
    context 'when its a overall topic' do
      let(:review_topic) { FactoryGirl.create(:teachers_topic) }
      subject { review_topic.overall? }
      it { is_expected.to eq(false) }
    end
  end

end