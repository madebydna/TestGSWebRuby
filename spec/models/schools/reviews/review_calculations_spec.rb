require 'spec_helper'

describe ReviewCalculations do

  let!(:reviews_array) do
    reviews_array = Array.new
    reviews_array.extend ReviewCalculations
    reviews_array.extend ReviewScoping
  end
  let(:five_star_review_value_4) { FactoryGirl.build(:five_star_review, answer_value: 4) }
  let(:five_star_review_value_3) { FactoryGirl.build(:five_star_review, answer_value: 3) }
  let(:five_star_review_value_1) { FactoryGirl.build(:five_star_review, answer_value: 1) }
  let(:non_numeric_review) { FactoryGirl.build(:teacher_effectiveness_review) }
  let(:user_1) { FactoryGirl.build(:verified_user) }
  let(:user_2) { FactoryGirl.build(:verified_user) }

  subject { reviews_array }

  shared_context 'with 2 overall reviews values: 4 & 3 AND 1 non-numeric review' do
    before do
      reviews_array << five_star_review_value_4
      reviews_array << five_star_review_value_3
      reviews_array << non_numeric_review
    end
  end

  shared_context 'with 4 overall reviews values: 4,3,3,1' do
    before do
      reviews_array << five_star_review_value_4
      reviews_array << five_star_review_value_3
      reviews_array << five_star_review_value_3
      reviews_array << five_star_review_value_1
    end
  end

  shared_context 'with three reviews with a single user and two reviews with a different user' do
    before do
      reviews_array << FactoryGirl.build(:five_star_review, user: user_1)
      reviews_array << FactoryGirl.build(:five_star_review, user: user_1)
      reviews_array << FactoryGirl.build(:five_star_review, user: user_1)
      reviews_array << FactoryGirl.build(:five_star_review, user: user_2)
      reviews_array << FactoryGirl.build(:five_star_review, user: user_2)
    end
  end

  describe '#rating_scores_hash' do
    it 'should return a hash' do
      expect(subject.rating_scores_hash).to be_a(Hash)
    end
  end

  describe '#score_distribution_with_percentage' do

    with_shared_context 'with 2 overall reviews values: 4 & 3 AND 1 non-numeric review' do
      it 'should return nil if reviews come from different questions' do
        expect(subject.score_distribution_with_percentage).to eq(nil)
      end
    end

    with_shared_context 'with 4 overall reviews values: 4,3,3,1' do

      it 'should return an array with five hashes' do
        expect(subject.score_distribution_with_percentage).to be_a(Array)
        expect(subject.score_distribution_with_percentage.count).to eq(5)
      end

      it 'should return hashes with the keys: count, percentage and label' do
        keys = [:count, :percentage, :label]
        subject.score_distribution_with_percentage.each do |hash|
          expect((hash.keys - keys).count).to eq(0)
        end
      end

      it 'should have correct values for each hash' do
        example_distribution = [
          {count: 0, percentage: '0',label: '5 stars' },
          {count: 1, percentage: '25',label: '4 stars' },
          {count: 2, percentage: '50', label: '3 stars' },
          {count: 0, percentage: '0',label: '2 stars' },
          {count: 1, percentage: '25', label: '1 star' },
        ]
        subject.score_distribution_with_percentage.each_with_index do |hash, index|
          expect(hash).to eq(example_distribution[index])
        end
      end
    end

    context 'with non overall reviews' do
      example_distribution = [
        {count: 3, percentage: '30',label: 'Highly disagree' },
        {count: 1, percentage: '10',label: 'Disagree' },
        {count: 5, percentage: '50', label: 'Neutral' },
        {count: 0, percentage: '0',label: 'Agree' },
        {count: 1, percentage: '10', label: 'Highly agree' },
      ]

      it 'should have correct values for non overall reviews' do
        example_distribution.each  do |hash|
          hash[:count].times do |i| 
            reviews_array << FactoryGirl.build(:teacher_effectiveness_review, answer_value: hash[:label])
          end
        end
        expect(example_distribution - subject.score_distribution_with_percentage).to eq([])
      end

    end
  end 

  describe '#score_distribution' do
    with_shared_context 'with 4 overall reviews values: 4,3,3,1' do
      it 'should return a hash' do
        expect(subject.score_distribution).to be_a(Hash)
      end
      it 'should return hash with keys for each value' do
        expect(subject.score_distribution).to have_key("4")
        expect(subject.score_distribution).to have_key("3")
        expect(subject.score_distribution).to have_key("1")
      end
      it 'should return hash with correct count of review for each value' do
        expect(subject.score_distribution["4"]).to eq(1)
        expect(subject.score_distribution["3"]).to eq(2)
        expect(subject.score_distribution["1"]).to eq(1)
      end
    end

    context 'with reviews that have nil value' do
     include_context 'with 4 overall reviews values: 4,3,3,1'
     let(:five_star_review_value_nil) { FactoryGirl.build(:five_star_review, answer_value: nil) }
      before { subject << five_star_review_value_nil }
      it 'should return hash with no key for nil' do
        expect(subject.score_distribution).to_not have_key(nil)
      end
    end
  end

  describe '#total_score' do
    context 'with empty array' do
      it 'should return a integer' do
        expect(subject.total_score).to be_a(Integer)
      end
      it 'should return 0' do
        expect(subject.total_score).to eq(0)
      end
    end
    with_shared_context 'with 2 overall reviews values: 4 & 3 AND 1 non-numeric review' do
      it 'should return a integer' do
        expect(subject.total_score).to be_a(Integer)
      end
      it 'should return the total numeric value of answers' do
        total_score_of_3_and_4 = 7
        expect(subject.total_score).to eq(total_score_of_3_and_4)
      end
    end
    context 'with 2 overall reviews values: 4 & 3 saved as strings' do
      let(:five_star_review_value_4_str) { FactoryGirl.build(:five_star_review, answer_value: '4') }
      let(:five_star_review_value_3_str) { FactoryGirl.build(:five_star_review, answer_value: '3') }
      before do
        subject << five_star_review_value_4_str
        subject << five_star_review_value_3_str
      end
      it 'should return a integer' do
        expect(subject.total_score).to be_a(Integer)
      end
      it 'should return the total numeric value of answers' do
        total_score_of_3_and_4 = 7
        expect(subject.total_score).to eq(total_score_of_3_and_4)
      end
    end
  end

  describe '#average score' do
    context 'with 0 reviews with ratings' do
      before do
        allow(subject).to receive(:count_having_numeric_answer).and_return(0)
        allow(subject).to receive(:total_score).and_return(0)
      end
      it 'should return correct zero' do
        expect(subject.average_score).to eq(0)
      end
    end
    context 'with 2 overall reviews values: 4 & 3' do
      before do
        allow(subject).to receive(:count_having_numeric_answer).and_return(2)
        allow(subject).to receive(:total_score).and_return(7)
      end
      it 'should return correct average' do
        average_of_3_and_4 = 3.5
        expect(subject.average_score).to eq(average_of_3_and_4)
      end
    end
  end

  describe '#topical_review_summary' do
    let (:teacher_effectiveness_1) { build(:teacher_effectiveness_review, answer_value: 'Neutral') }
    let (:teacher_effectiveness_2) { build(:teacher_effectiveness_review, answer_value: 'Disagree') }
    let (:homework_1) { build(:homework_review, answer_value: 'Strongly disagree') }
    let (:homework_bad) { build(:homework_review, answer_value: nil) }

    it 'should return the correct average text response and the total number of responses per topic' do
      result_hash = {
          'Teachers' => {:count => 2, :average => 'Neutral'},
          'Homework' => {:count => 1, :average => 'Strongly disagree'}
      }
      subject << teacher_effectiveness_1
      subject << teacher_effectiveness_2
      subject << homework_1
      expect(subject.topical_review_summary).to eq(result_hash)
    end

    it 'should handle reviews with no valid answers' do
      result_hash = {
          'Teachers' => {:count => 2, :average => 'Neutral'}
      }
      subject << teacher_effectiveness_1
      subject << teacher_effectiveness_2
      subject << homework_bad
      expect(subject.topical_review_summary).to eq(result_hash)
    end
  end

  describe '#having numeric answer' do
    context 'with empty array' do
      it 'it should return empty array' do
        expect(subject.having_numeric_answer).to eq ([])
      end
      with_shared_context 'with 2 overall reviews values: 4 & 3 AND 1 non-numeric review' do
        it 'should return array' do
          expect(subject.having_numeric_answer).to be_a(Array)
        end
        it 'should return array with two reviews' do
          expect(subject.having_numeric_answer.count).to eq(2)
          expect(subject.having_numeric_answer).to eq([five_star_review_value_4, five_star_review_value_3])
        end
      end
    end
  end

  describe '#count_having_rating' do
    it 'it should return count of reviews' do
      numeric_reviews = [five_star_review_value_4, five_star_review_value_3]
      allow(subject).to receive(:having_numeric_answer).and_return(numeric_reviews)
      expect(subject.count_having_numeric_answer).to eq(2)
    end
  end

  describe '#number_of_distinct_users' do
    subject { reviews_array.number_of_distinct_users }
    with_shared_context 'with three reviews with a single user and two reviews with a different user' do
      it { is_expected.to eq(2) }
    end
  end
end
