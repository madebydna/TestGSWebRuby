require 'spec_helper'

describe ReviewScoping do

  let!(:reviews_array) do
    reviews_array = Array.new
    reviews_array.extend ReviewScoping
  end
  let(:five_star_parent_review1) { FactoryGirl.build(:five_star_review) }
  let(:five_star_parent_review2) { FactoryGirl.build(:five_star_review) }
  let(:five_star_teacher_review1) { FactoryGirl.build(:five_star_review) }
  let(:five_star_student_review1) { FactoryGirl.build(:five_star_review) }
  let(:teacher_effectiveness_principal_review) { FactoryGirl.build(:teacher_effectiveness_review) }
  let(:teacher_effectiveness_unknown_review) { FactoryGirl.build(:teacher_effectiveness_review) }

  subject { reviews_array }

  shared_context 'with 4 five star reviews users: 2 parent, 1 students, 1 teacher; 2 teacher effectiveness users: 1 principal, 1 unknown' do
    before do
      allow(five_star_parent_review1).to receive(:user_type).and_return('parent')
      allow(five_star_parent_review2).to receive(:user_type).and_return('parent')
      allow(five_star_student_review1).to receive(:user_type).and_return('student')
      allow(five_star_teacher_review1).to receive(:user_type).and_return('teacher')
      allow(teacher_effectiveness_principal_review).to receive(:user_type).and_return('principal')
      allow(teacher_effectiveness_unknown_review).to receive(:user_type).and_return('unknown')
      subject.push(five_star_parent_review1, five_star_student_review1,
                   five_star_parent_review2, five_star_teacher_review1,
                   teacher_effectiveness_principal_review, teacher_effectiveness_unknown_review
      )
    end
  end

  describe '#by_user_type' do
    with_shared_context 'with 4 five star reviews users: 2 parent, 1 students, 1 teacher; 2 teacher effectiveness users: 1 principal, 1 unknown' do
      it 'should return a hash' do
        expect(subject.by_user_type).to be_a(Hash)
      end
      it 'should return hash with correct topic keys for each user type' do
        %w(student teacher parent principal unknown).each do |type|
          expect(subject.by_user_type).to have_key(type)
        end
      end
      it 'should return hash with correct count of reviews in each user type' do
        expect(subject.by_user_type['parent'].count).to eq(2)
        expect(subject.by_user_type['student'].count).to eq(1)
        expect(subject.by_user_type['teacher'].count).to eq(1)
        expect(subject.by_user_type['principal'].count).to eq(1)
        expect(subject.by_user_type['unknown'].count).to eq(1)
      end
      it 'should extend each array with ReviewScoping and ReviewCalculations modules' do
        subject.by_user_type.each do |key, reviews_array|
          expect(reviews_array).to respond_to(:five_star_rating_reviews, :has_principal_review?, :score_distribution)
        end
      end
    end
  end

  describe '#by_topic' do
    with_shared_context 'with 4 five star reviews users: 2 parent, 1 students, 1 teacher; 2 teacher effectiveness users: 1 principal, 1 unknown' do
      it 'should return a hash' do
        expect(subject.by_topic).to be_a(Hash)
      end
      it 'should return hash with correct topic keys' do
        ['Overall', 'Teachers'].each do |type|
          expect(subject.by_topic).to have_key(type)
        end
      end
      it 'should return hash with correct count of reviews in each topic' do
        expect(subject.by_topic['Overall'].count).to eq(4)
        expect(subject.by_topic['Teachers'].count).to eq(2)
      end
      it 'should return hash an array of reviews as values' do
        expect(subject.by_topic['Overall']).to include(five_star_parent_review1)
        expect(subject.by_topic['Overall']).to include(five_star_parent_review2)
        expect(subject.by_topic['Overall']).to include(five_star_student_review1)
        expect(subject.by_topic['Overall']).to include(five_star_teacher_review1)
        expect(subject.by_topic['Teachers']).to include(teacher_effectiveness_principal_review)
        expect(subject.by_topic['Teachers']).to include(teacher_effectiveness_unknown_review)
      end
      it 'should extend each array with ReviewScoping and ReviewCalculations modules' do
        subject.by_topic.each do |key, reviews_array|
          expect(reviews_array).to respond_to(:five_star_rating_reviews, :has_principal_review?, :score_distribution)
        end
      end
    end
  end

  describe '#five_star_rating_reviews' do
    with_shared_context 'with 4 five star reviews users: 2 parent, 1 students, 1 teacher; 2 teacher effectiveness users: 1 principal, 1 unknown' do
      it 'should return an array' do
        expect(subject.five_star_rating_reviews).to be_a(Array)
      end
      it 'should return Array with only overall topic reviews' do
        subject.five_star_rating_reviews.each do |review|
          expect(review.question.review_topic.name).to eq('Overall')
        end
      end
    end
  end

  %w(parent student principal).each do |user_type|
    describe "#{user_type}_reviews" do
      with_shared_context 'with 4 five star reviews users: 2 parent, 1 students, 1 teacher; 2 teacher effectiveness users: 1 principal, 1 unknown' do
        it 'should return an array' do
          expect(subject.send("#{user_type}_reviews")).to be_a(Array)
        end
        it "should return an array with only #{user_type} reviews" do
          subject.send("#{user_type}_reviews").each do |review|
            expect(review.user_type).to eq(user_type)
          end
        end
      end
    end
  end

  describe '#has_principal_review?' do
    with_shared_context 'with 4 five star reviews users: 2 parent, 1 students, 1 teacher; 2 teacher effectiveness users: 1 principal, 1 unknown' do
      it 'should return true' do
        expect(subject.has_principal_review?).to be_truthy
      end
    end
    context 'with no principal review' do
      before { subject - [teacher_effectiveness_principal_review] }
      it 'should return false' do
        expect(subject.has_principal_review?).to be_falsey
      end
    end
  end

  describe '#principal_review' do
    with_shared_context 'with 4 five star reviews users: 2 parent, 1 students, 1 teacher; 2 teacher effectiveness users: 1 principal, 1 unknown' do
      it 'should return the one principal review' do
        expect(subject.principal_review).to eq(teacher_effectiveness_principal_review)
      end
      context 'a second principal review added to reviews array' do
        let(:second_principal_review) { FactoryGirl.build(:five_star_review) }
        before do
          allow(second_principal_review).to receive(:user_type).and_return('principal')
          subject << second_principal_review
        end
        it 'should return only the first principal review' do
          expect(subject.principal_review).to eq(teacher_effectiveness_principal_review)
          expect(subject.principal_review).to_not eq(second_principal_review)
        end
      end
    end
    context 'with no principal review' do
      before { subject - [teacher_effectiveness_principal_review] }
      it 'should return nil' do
        expect(subject.principal_review).to eq(nil)
      end
    end
  end

  shared_context 'with two reviews with comments and one review without comments' do
    let(:review_with_comment) { FactoryGirl.build(:review) }
    let(:review_with_comment2) { FactoryGirl.build(:review) }
    let(:review_without_comment) { FactoryGirl.build(:review, comment: '') }

    before do
      subject.push(review_with_comment, review_with_comment2, review_without_comment)
    end
  end

  describe '#having_comments' do
    with_shared_context 'with two reviews with comments and one review without comments' do
      it 'should return array' do
        expect(subject.having_comments).to be_a(Array)
      end
      it 'should return an array with two reviews' do
        expect(subject.having_comments.count).to eq(2)
        expect(subject.having_comments).to eq([review_with_comment, review_with_comment2])
      end
      it 'should extend the array with ReviewScoping and ReviewCalculations modules' do
        expect(subject.having_comments).to respond_to(:five_star_rating_reviews, :has_principal_review?, :score_distribution)
      end
    end
  end

  describe '#number_with_comments' do
    with_shared_context 'with two reviews with comments and one review without comments' do
      it 'should return count of reviews with comments' do
        expect(subject.number_with_comments).to eq(2)
      end
    end
  end

  describe '#empty_extended_array' do
      it 'should return an empty array' do
        expect(subject.empty_extended_array).to be_a(Array)
        expect(subject.empty_extended_array.empty?).to be_truthy
      end
      it 'should extend the array with ReviewScoping and ReviewCalculations modules' do
        expect(subject.having_comments).to respond_to(:five_star_rating_reviews, :has_principal_review?, :score_distribution)
      end
  end

end