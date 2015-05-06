require 'spec_helper'

describe ReviewCaching do


  shared_context 'with reviews array with 4 five star reviews users: 2 parents, 2 students; 2 teacher effectiveness users: 1 parent, 1 student' do
    let!(:reviews_array) do
      reviews_array = Array.new
      reviews_array.extend ReviewCalculations
      reviews_array.extend ReviewScoping
    end

  let(:five_star_parent_review1_val_4) { FactoryGirl.build(:five_star_review, answer_value: 4) }
  let(:five_star_parent_review2_val_3) { FactoryGirl.build(:five_star_review, answer_value: 3) }
  let(:five_star_student_review1_val_2) { FactoryGirl.build(:five_star_review, answer_value: 2) }
  let(:five_star_student_review2_val_4) { FactoryGirl.build(:five_star_review, answer_value: 4) }
  let(:teacher_effectiveness_parent_review) { FactoryGirl.build(:teacher_effectiveness_review) }
  let(:teacher_effectiveness_parent_review2) { FactoryGirl.build(:teacher_effectiveness_review, comment: nil) }
  let(:teacher_effectiveness_student_review) { FactoryGirl.build(:teacher_effectiveness_review) }
  let(:teacher_effectiveness_student_review2) { FactoryGirl.build(:teacher_effectiveness_review, comment: nil) }

    before do
      allow(five_star_parent_review1_val_4).to receive(:user_type).and_return('parent')
      allow(five_star_parent_review2_val_3).to receive(:user_type).and_return('parent')
      allow(five_star_student_review1_val_2).to receive(:user_type).and_return('student')
      allow(five_star_student_review2_val_4).to receive(:user_type).and_return('student')
      allow(teacher_effectiveness_parent_review).to receive(:user_type).and_return('parent')
      allow(teacher_effectiveness_parent_review2).to receive(:user_type).and_return('parent')
      allow(teacher_effectiveness_student_review).to receive(:user_type).and_return('student')
      allow(teacher_effectiveness_student_review2).to receive(:user_type).and_return('student')
      reviews_array.push(five_star_parent_review1_val_4, five_star_parent_review2_val_3,
                   five_star_student_review1_val_2, five_star_student_review2_val_4,
                   teacher_effectiveness_student_review, teacher_effectiveness_parent_review
      )
    end

  end

  with_shared_context 'with reviews array with 4 five star reviews users: 2 parents, 2 students; 2 teacher effectiveness users: 1 parent, 1 student' do
    subject { ReviewCaching.new(reviews_array) }

    describe '#initialize' do
      it 'sets reviews to be an array' do
        expect(subject.reviews).to be_a(Array)
      end

      it 'sets extends reviews with ReviewScoping and ReviewCalculations modules' do
        expect(subject.reviews).to respond_to(:five_star_rating_reviews, :has_principal_review?, :score_distribution)
      end
    end

    describe '#review_counts_per_user_type' do
      it 'should return a hash' do
        expect(subject.review_counts_per_user_type).to be_a(Hash)
      end
      it 'should return a hash with correct count for reviews by user_type for all topics' do
        expect(subject.review_counts_per_user_type[:all]).to eq(6)
        expect(subject.review_counts_per_user_type[:parent]).to eq(3)
        expect(subject.review_counts_per_user_type[:student]).to eq(3)
      end
      it 'should not consider reviews that dont have comments' do
        reviews_array.push(teacher_effectiveness_parent_review2)
        reviews_array.push(teacher_effectiveness_student_review2)
        expect(subject.review_counts_per_user_type[:all]).to eq(6)
        expect(subject.review_counts_per_user_type[:parent]).to eq(3)
        expect(subject.review_counts_per_user_type[:student]).to eq(3)
      end
    end

    describe '#rating_scores_per_user_type' do
      it 'should return a hash' do
        expect(subject.rating_scores_per_user_type).to be_a(Hash)
      end
      %w(parent student overall).each do |key|
        it "should return a hash with the key: #{key}" do
          expect(subject.rating_scores_per_user_type).to have_key(key.to_sym)
        end

        context "should return correct values for key: #{key}" do
          answer_key = {'parent' => {'avg_score' => 4, 'total' => 7, 'counter' => 2},
                        'student' => {'avg_score' => 3, 'total' => 6, 'counter' => 2},
                        'overall' => {'avg_score' => 3, 'total' => 13, 'counter' => 4}}
          %w(avg_score total counter).each do |value_key|
            it "should have a value of #{answer_key[key][value_key]} for #{value_key}" do
              expect(subject.rating_scores_per_user_type[key.to_sym][value_key]).to eq(answer_key[key][value_key])
            end
          end
        end
      end
    end

    describe '#cal_review_data' do
      it 'should return a hash' do
        expect(subject.calc_review_data).to be_a(Hash)
      end
      %w(star_counts rating_averages review_filter_totals).each do |key|
        it "should return a hash with the key: #{key}" do
          expect(subject.calc_review_data).to have_key(key.to_sym)
        end
      end
    end

    it 'should return correct star counts' do
      expect(
        subject.calc_review_data[:star_counts]
      ).to eq(
             Hashie::Mash.new(
               reviews_array.five_star_rating_reviews.score_distribution
             )
           )
    end

  end
end
