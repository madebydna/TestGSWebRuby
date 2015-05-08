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
      context 'with access to review cache' do
        it 'should try and get number of reviews with comments from review cache' do
          subject.stub_chain('review_cache.num_reviews').and_return(8)
          expect(subject.number_of_reviews_with_comments).to eq(8)
        end
      end
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


    describe '#five_star_rating_score_distribution' do
      context 'with access to review cache' do
        it 'should try and get the five star rating distribution from review cache' do
          subject.stub_chain('review_cache.star_counts').and_return(4)
          expect(subject.five_star_rating_score_distribution).to eq(4)
        end
      end
      context 'without access to review cache' do
        it 'should return number of 5 star ratings' do
          subject.stub_chain('review_cache.star_counts').and_return(nil)
          subject.stub_chain('reviews.five_star_rating_reviews.score_distribution').and_return(3)
          expect(subject.five_star_rating_score_distribution).to eq(3)
        end
      end
    end

    describe '.calc_review_data' do
      it 'should return an instance of Review Caching' do
        pending ('ask Samson how to test this')
        reviews = []
        expect(SchoolReviews.calc_review_data(reviews)).to be_a(ReviewCaching)
      end
    end
  end

end