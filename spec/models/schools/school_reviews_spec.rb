require 'spec_helper'

describe SchoolReviews do

  context 'initialized with only a school with no reviews' do
    let(:school) { FactoryGirl.build(:school) }
    let!(:school_reviews) do
      school_reviews = SchoolReviews.new do
        [].extend(ReviewScoping).extend(ReviewCalculations)
      end
    end
    subject { school_reviews }

    describe '#initialize' do
      it 'sets reviews_proc to be proc' do
        expect(subject.reviews_proc).to be_a(Proc)
      end
    end

    describe '#reviews' do
      it 'should return an empty array' do
        expect(subject.reviews).to eq([])
      end
      it 'should return an array mixed with modules ReviewScoping and ReviewCalculations' do
        expect(subject.reviews).to respond_to(:five_star_rating_reviews, :has_principal_review?, :score_distribution)
      end
    end

    describe '#number_of_active_reviews' do
      context 'with access to review cache' do
        it 'should try and get number_of_active_reviews from review cache' do
          subject.stub_chain('review_cache.num_reviews').and_return(8)
          expect(subject.number_of_active_reviews).to eq(8)
        end
      end
      context 'without access to review cache' do
        it 'should return number of reviews' do
          subject.stub_chain('review_cache.num_reviews').and_return(nil)
          subject.stub_chain('reviews.size').and_return(10)
          expect(subject.number_of_active_reviews).to eq(10)
        end
      end
    end

    describe '#average_5_star_rating' do
      context 'with access to review cache' do
        it 'should try and get star_rating from review cache' do
          subject.stub_chain('review_cache.star_rating').and_return(8)
          expect(subject.average_5_star_rating).to eq(8)
        end
      end
      context 'without access to review cache' do
        it 'should return a rounded average 5 star rating score' do
          subject.stub_chain('review_cache.star_rating').and_return(nil)
          subject.stub_chain('reviews.five_star_rating_reviews.average_score').and_return(3.5)
          expect(subject.average_5_star_rating).to eq(4)
        end
      end
    end

    describe '#number_of_reviews_with_coments' do
      context 'without access to review cache' do
        it 'should return the number of reviews with comments' do
          subject.stub_chain('review_cache.num_reviews').and_return(nil)
          subject.stub_chain('reviews.number_with_comments').and_return(3)
          expect(subject.number_of_reviews_with_comments).to eq(3)
        end
      end
    end

    describe '#number_of_5_star_ratings' do
      context 'with access to review cache' do
        it 'should try and get the number of 5 star ratings from review cache' do
          subject.stub_chain('review_cache.num_ratings').and_return(4)
          expect(subject.number_of_5_star_ratings).to eq(4)
        end
      end
      context 'without access to review cache' do
        it 'should return number of 5 star ratings' do
          subject.stub_chain('review_cache.num_ratings').and_return(nil)
          subject.stub_chain('reviews.five_star_rating_reviews.count_having_numeric_answer').and_return(3)
          expect(subject.number_of_5_star_ratings).to eq(3)
        end
      end
    end

    describe '#promote_review!' do
      let!(:school_reviews) do
        school_reviews = SchoolReviews.new do
          FactoryGirl.build_list(:five_star_review, 5).extend(ReviewScoping).extend(ReviewCalculations)
        end
      end

      it 'should handle review id that is not in reviews list' do
        expect { subject.promote_review!(999999) }.to_not change { subject.map(&:id).to_s }
      end

      it 'should promote review to top of array' do
        expect { subject.promote_review!(subject[3].id) }.to change { subject.map(&:id).to_s }
      end

      it 'other reviews should be sorted the same way' do
        fourth_item = subject[3]
        expect { subject.promote_review!(fourth_item.id) }.to_not change { (subject - [fourth_item]).map(&:id).to_s }
      end
    end

  end

end