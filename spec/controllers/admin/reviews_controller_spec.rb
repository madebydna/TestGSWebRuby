require 'spec_helper'

describe Admin::ReviewsController do

  it 'should have the right methods' do
    expect(controller).to respond_to :deactivate
    expect(controller).to respond_to :activate
    expect(controller).to respond_to :report
  end

  describe '#update' do
    before do
      request.env['HTTP_REFERER'] = 'www.greatschools.org/blah'
    end
    after do
      expect(response).to redirect_to request.env['HTTP_REFERER']
    end

    it 'should update the review if one is found' do
      review = FactoryGirl.build(:review)
      allow(Review).to receive(:find).and_return(review)
      expect(review).to receive(:update_attributes).and_return true
      post :update, id: 1, review: { comment: 'Foo' }
    end

    it 'should handle update failure by setting flash message' do
      review = FactoryGirl.build(:review)
      allow(Review).to receive(:find).and_return(review)
      expect(review).to receive(:update_attributes).and_return false
      expect(controller).to receive(:flash_error)
      post :update, id: 1, review: { comment: 'Foo' }
    end
  end

  describe '#report' do
    before do
      request.env['HTTP_REFERER'] = 'www.greatschools.org/blah'
    end
    after do
      expect(response).to redirect_to request.env['HTTP_REFERER']
    end

    it 'should report the review if one is found' do
      allow(controller).to receive(:logged_in?).and_return(true)
      comment = 'foo'
      reported_entity = double(ReportedReview).as_null_object
      review = FactoryGirl.build(:review)
      allow(Review).to receive(:find).and_return(review)
      expect(review).to receive(:build_reported_review).with(comment, 'user-reported') {
        reported_entity
      }
      expect(reported_entity).to receive(:save).and_return(true)
      expect(controller).to receive(:flash_notice)
      post :report, id: 1, reason: comment
    end

    it 'should handle save failure by setting flash message' do
      allow(controller).to receive(:logged_in?).and_return(true)
      comment = 'foo'
      review_flag = double(ReportedReview).as_null_object
      review = FactoryGirl.build(:review)
      allow(Review).to receive(:find).and_return(review)
      expect(review).to receive(:build_reported_review).with(comment, 'user-reported') {
        review_flag
      }
      expect(review_flag).to receive(:save).and_return(false)
      expect(controller).to receive(:flash_error)
      post :report, id: 1, reason: comment
    end
  end

  describe '#moderation' do
    let(:school) { FactoryGirl.build(:school) }
    let(:flagged_reviews) { FactoryGirl.build_list(:review, 3, :flagged) }
    let(:valid_reviews) { FactoryGirl.build_list(:review, 3) }
    let(:user) {FactoryGirl.build(:user)}


    before do
      allow(controller).to receive(:flagged_reviews).and_return flagged_reviews
      allow(controller).to receive(:find_reviews_by_user).with(user).and_return valid_reviews
      allow(controller).to receive(:find_reviews_reported_by_user).and_return flagged_reviews
    end

    it 'should not look for a school if not provided a state and school ID' do
      expect(School).to_not receive(:find_by_state_and_id)
      get :moderation
    end

    context 'provided a state and school ID' do
      before do
        expect(School).to receive(:find_by_state_and_id).with('ca', '1').and_return(school)
        allow(school).to receive(:reviews_that_have_ever_been_flagged).and_return(flagged_reviews)
      end

      it 'should look for a school if provided a state and school ID' do
        expect(School).to_not receive(:find_by_state_and_id)
        get :moderation, state: 'ca', school_id: 1
      end

      it 'should expose reported reviews to the view' do
        get :moderation, state: 'ca', school_id: 1
        expect(assigns[:reported_reviews]).to eq flagged_reviews
      end
    end

    context 'provided a search string' do

      it 'should look for reviews and flags by user if email is provided' do
        expect(User).to receive(:find_by_email).and_return user
        expect(controller).to receive(:find_reviews_by_user).with(user).and_return valid_reviews
        expect(controller).to receive(:find_reviews_reported_by_user).and_return flagged_reviews

        get :moderation, review_moderation_search_string: 'someone@domain.com'
      end

      it 'should look for reviews by IP if IP is provided' do
        pending 'TODO: Figure out IPs for topical reviews'
        expect(SchoolRating).to receive(:by_ip).and_return valid_reviews

        get :moderation, review_moderation_search_string: '12.2.3.3'
        expect(assigns[:banned_ip]).to_not be_nil
        expect(controller.instance_variable_get(:@banned_ip).ip).to eq('12.2.3.3')
      end

    end

  end

  describe '#flagged reviews' do
    let(:school) { FactoryGirl.build(:school) }
    let(:reviews) { FactoryGirl.build_list(:review, 3) }

    it 'should return any previously flagged review for school if school is set' do
      pending('PT-1213: TODO: Fix rspec or code')
      controller.instance_variable_set(:@school, school)
      reviews = double('reviews')
      expect(reviews).to receive(:order).and_return reviews
      expect(reviews).to receive(:page).and_return reviews
      expect(reviews).to receive(:per).and_return reviews
      allow(school).to receive(:reviews).and_return reviews
      expect(controller.send :flagged_reviews).to eq(reviews)
    end

    it 'should return flagged reviews if no school is set' do
      pending('PT-1213: TODO: Fix rspec or code')
      reviews = double('reviews')
      expect(reviews).to receive(:order).and_return reviews
      expect(reviews).to receive(:page).and_return reviews
      expect(reviews).to receive(:per).and_return reviews
      expect(reviews).to receive(:flagged).and_return reviews

      expect(Review).to receive(:where).with(status: %w[p d r a]).and_return reviews
      expect(controller.send :flagged_reviews).to eq(reviews)
    end
  end


end
