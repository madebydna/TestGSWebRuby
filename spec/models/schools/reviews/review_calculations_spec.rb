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

  subject { reviews_array }

  shared_context 'with 2 five star reviews values: 4 & 3 AND 1 non-numeric review' do
    before do
      subject << five_star_review_value_4
      subject << five_star_review_value_3
      subject << non_numeric_review
    end
  end

  shared_context 'with 4 five star reviews values: 4,3,3,1' do
    before do
      subject << five_star_review_value_4
      subject << five_star_review_value_3
      subject << five_star_review_value_3
      subject << five_star_review_value_1
    end
  end

  describe '#rating_scores_hash' do
    it 'should return a hash' do
      expect(subject.rating_scores_hash).to be_a(Hash)
    end
  end

  describe '#score_distribution' do
    with_shared_context 'with 4 five star reviews values: 4,3,3,1' do
      it 'should return a hash' do
        expect(subject.score_distribution).to be_a(Hash)
      end
      it 'should return hash with keys for each value' do
        expect(subject.score_distribution).to have_key(4)
        expect(subject.score_distribution).to have_key(3)
        expect(subject.score_distribution).to have_key(1)
      end
      it 'should return hash with correct count of review for each value' do
        expect(subject.score_distribution[4]).to eq(1)
        expect(subject.score_distribution[3]).to eq(2)
        expect(subject.score_distribution[1]).to eq(1)
      end
    end

    context 'with reviews that have nil value' do
     include_context 'with 4 five star reviews values: 4,3,3,1'
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
    with_shared_context 'with 2 five star reviews values: 4 & 3 AND 1 non-numeric review' do
      it 'should return a integer' do
        expect(subject.total_score).to be_a(Integer)
      end
      it 'should return the total numeric value of answers' do
        total_score_of_3_and_4 = 7
        expect(subject.total_score).to eq(total_score_of_3_and_4)
      end
    end
    context 'with 2 five star reviews values: 4 & 3 saved as strings' do
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
    context 'with 2 five star reviews values: 4 & 3' do
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

  describe '#having numeric answer' do
    context 'with empty array' do
      it 'it should return empty array' do
        expect(subject.having_numeric_answer).to eq ([])
      end
      with_shared_context 'with 2 five star reviews values: 4 & 3 AND 1 non-numeric review' do
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

end
