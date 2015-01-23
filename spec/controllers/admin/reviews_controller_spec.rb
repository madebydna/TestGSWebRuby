require 'spec_helper'

describe Admin::ReviewsController do

  it 'should have the right methods' do
    expect(controller).to respond_to :disable
    expect(controller).to respond_to :publish
  end

  describe '#publish' do
    before do
      request.env['HTTP_REFERER'] = 'www.greatschools.org/blah'
    end
    after do
      expect(response).to redirect_to request.env['HTTP_REFERER']
    end

    it 'should publish a review if one is found' do
      review = FactoryGirl.build(:unpublished_review)
      allow(SchoolRating).to receive(:find).and_return(review)
      allow(review).to receive(:save).and_return true
      post :publish, id: 1
      expect(review).to be_published
    end

    it 'should handle case where review is not found' do
      allow(SchoolRating).to receive(:find).and_return(nil)
      post :publish, id: 1
    end

    it 'should handle failure to save by setting flash message' do
      review = FactoryGirl.build(:unpublished_review)
      allow(SchoolRating).to receive(:find).and_return(review)
      allow(review).to receive(:save).and_return false
      expect(controller).to receive(:flash_error)
      post :publish, id: 1
    end
  end

  describe '#disable' do
    before do
      request.env['HTTP_REFERER'] = 'www.greatschools.org/blah'
    end
    after do
      expect(response).to redirect_to request.env['HTTP_REFERER']
    end

    it 'should disable a review if one is found' do
      review = FactoryGirl.build(:unpublished_review)
      allow(SchoolRating).to receive(:find).and_return(review)
      allow(review).to receive(:save).and_return true
      post :disable, id: 1
      expect(review).to be_disabled
    end

    it 'should handle case where review is not found' do
      allow(SchoolRating).to receive(:find).and_return(nil)
      post :disable, id: 1
    end

    it 'should handle failure to save by setting flash message' do
      review = FactoryGirl.build(:unpublished_review)
      allow(SchoolRating).to receive(:find).and_return(review)
      allow(review).to receive(:save).and_return false
      expect(controller).to receive(:flash_error)
      post :disable, id: 1
    end
  end

  describe '#update' do
    before do
      request.env['HTTP_REFERER'] = 'www.greatschools.org/blah'
    end
    after do
      expect(response).to redirect_to request.env['HTTP_REFERER']
    end

    it 'should update the review if one is found' do
      review = FactoryGirl.build(:unpublished_review)
      allow(SchoolRating).to receive(:find).and_return(review)
      expect(review).to receive(:update_attributes).and_return true
      post :update, id: 1
    end

    it 'should handle update failure by setting flash message' do
      review = FactoryGirl.build(:unpublished_review)
      allow(SchoolRating).to receive(:find).and_return(review)
      expect(review).to receive(:update_attributes).and_return false
      expect(controller).to receive(:flash_error)
      post :update, id: 1
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
      reason = 'foo'
      reported_entity = double(ReportedEntity)
      review = FactoryGirl.build(:school_rating)
      allow(SchoolRating).to receive(:find).and_return(review)
      expect(ReportedEntity).to receive(:from_review).with(review, reason) {
        reported_entity
      }
      expect(reported_entity).to receive(:save).and_return(true)
      expect(controller).to receive(:flash_notice)
      post :report, id: 1, reason: reason
    end

    it 'should handle save failure by setting flash message' do
      reason = 'foo'
      reported_entity = double(ReportedEntity)
      review = FactoryGirl.build(:school_rating)
      allow(SchoolRating).to receive(:find).and_return(review)
      expect(ReportedEntity).to receive(:from_review).with(review, reason) {
        reported_entity
      }
      expect(reported_entity).to receive(:save).and_return(false)
      expect(controller).to receive(:flash_error)
      post :report, id: 1, reason: reason
    end
  end

  describe '#moderation' do
    let(:school) { FactoryGirl.build(:school) }
    let(:reported_entities) { FactoryGirl.build_list(:reported_review, 3) }
    let(:unprocessed_reviews) { FactoryGirl.build_list(:unpublished_review, 3) }
    let(:flagged_reviews) { FactoryGirl.build_list(:valid_school_rating, 3) }
    let(:valid_reviews) { FactoryGirl.build_list(:valid_school_rating, 3) }
    let(:user) {FactoryGirl.build(:user)}


    before do
      allow(controller).to receive(:unprocessed_reviews).and_return unprocessed_reviews
      allow(controller).to receive(:flagged_reviews).and_return flagged_reviews
      allow(controller).to receive(:reported_entities_for_reviews).and_return reported_entities
      allow(controller.class).to receive(:reported_entities_for_reviews).and_return reported_entities
      allow(controller).to receive(:find_reviews_by_user).with(user).and_return valid_reviews
      allow(controller).to receive(:find_reviews_reported_by_user).and_return reported_entities
      allow(SchoolRating).to receive(:by_ip).and_return valid_reviews
    end

    it 'should not look for a school if not provided a state and school ID' do
      expect(School).to_not receive(:find_by_state_and_id)
      get :moderation
    end

    context 'provided a state and school ID' do
      before do
        expect(School).to receive(:find_by_state_and_id).with('ca', '1').and_return(school)
      end

      it 'should look for a school if provided a state and school ID' do
        expect(School).to_not receive(:find_by_state_and_id)
        get :moderation, state: 'ca', school_id: 1
      end

      it 'should expose reported reviews to the view' do
        get :moderation, state: 'ca', school_id: 1
        expect(assigns[:reported_reviews]).to eq flagged_reviews
      end

      it 'should expose reported entities to the view' do
        get :moderation, state: 'ca', school_id: 1
        expect(assigns[:reported_entities]).to eq reported_entities
      end

      it 'should expose unprocessed reviews to the view' do
        get :moderation, state: 'ca', school_id: 1
        expect(assigns[:reviews_to_process]).to eq unprocessed_reviews
      end
    end

    context 'provided a search string' do

      it 'should look for reviews and flags by user if email is provided' do
        expect(User).to receive(:find_by_email).and_return user
        expect(controller).to receive(:find_reviews_by_user).with(user).and_return valid_reviews
        expect(controller).to receive(:reported_entities_for_reviews).and_return reported_entities
        expect(controller).to receive(:find_reviews_reported_by_user).and_return reported_entities

        get :moderation, review_moderation_search_string: 'someone@domain.com'
      end

      it 'should look for reviews by IP if IP is provided' do
        expect(SchoolRating).to receive(:by_ip).and_return valid_reviews
        expect(controller).to receive(:reported_entities_for_reviews).and_return reported_entities

        get :moderation, review_moderation_search_string: '12.2.3.3'
        expect(assigns[:banned_ip]).to_not be_nil
        expect(controller.instance_variable_get(:@banned_ip).ip).to eq('12.2.3.3')
      end

    end

  end

  describe '#unprocessed_reviews' do
    let(:school) { FactoryGirl.build(:school) }
    let(:reviews) { FactoryGirl.build_list(:valid_school_rating, 3) }

    it 'should return reviews for specific school if school is set' do
      controller.instance_variable_set(:@school, school)
      reviews = double('reviews')
      expect(reviews).to receive(:order).and_return reviews
      expect(reviews).to receive(:page).and_return reviews
      expect(reviews).to receive(:per).and_return reviews
      allow(school).to receive(:school_ratings).and_return reviews
      expect(controller.send :unprocessed_reviews).to eq(reviews)
    end

    it 'should return unpublished and held reviews if no school is set' do
      reviews = double('reviews')
      expect(reviews).to receive(:order).and_return reviews
      expect(reviews).to receive(:page).and_return reviews
      expect(reviews).to receive(:per).and_return reviews
      expect(SchoolRating).to receive(:where).with(status: %w[u h]).and_return reviews
      expect(controller.send :unprocessed_reviews).to eq(reviews)
    end
  end

  describe '#flagged reviews' do
    let(:school) { FactoryGirl.build(:school) }
    let(:reviews) { FactoryGirl.build_list(:valid_school_rating, 3) }

    it 'should return any previously flagged review for school if school is set' do
      controller.instance_variable_set(:@school, school)
      reviews = double('reviews')
      expect(reviews).to receive(:order).and_return reviews
      expect(reviews).to receive(:page).and_return reviews
      expect(reviews).to receive(:per).and_return reviews
      expect(reviews).to receive(:ever_flagged).and_return reviews
      allow(school).to receive(:school_ratings).and_return reviews
      expect(controller.send :flagged_reviews).to eq(reviews)
    end

    it 'should return flagged reviews if no school is set' do
      reviews = double('reviews')
      expect(reviews).to receive(:order).and_return reviews
      expect(reviews).to receive(:page).and_return reviews
      expect(reviews).to receive(:per).and_return reviews
      expect(reviews).to receive(:flagged).and_return reviews

      expect(SchoolRating).to receive(:where).with(status: %w[p d r a]).and_return reviews
      expect(controller.send :flagged_reviews).to eq(reviews)
    end
  end

  describe '.load_reported_entities_onto_reviews' do
    let(:reviews) { FactoryGirl.build_list(:valid_school_rating, 3) }

    it 'should correctly map reported entities to reviews' do
      reported_entities = []
      reported_entities += FactoryGirl.build_list(:reported_review, 3, reported_entity_id: reviews[0].id)
      reported_entities += FactoryGirl.build_list(:reported_review, 2, reported_entity_id: reviews[1].id)
      reported_entities += FactoryGirl.build_list(:reported_review, 1, reported_entity_id: reviews[2].id)

      controller.class.send :load_reported_entities_onto_reviews, reviews, reported_entities

      expect(reviews[0].reported_entities.size).to eq(3)
      expect(reviews[1].reported_entities.size).to eq(2)
      expect(reviews[2].reported_entities.size).to eq(1)
    end

    it 'handles empty arrays and nils' do
      controller.class.send :load_reported_entities_onto_reviews, [], []
      controller.class.send :load_reported_entities_onto_reviews, [], nil
      controller.class.send :load_reported_entities_onto_reviews, nil, []
      controller.class.send :load_reported_entities_onto_reviews, nil, nil
    end
  end

  describe '#reported_entities_for_reviews' do
    it 'should ask for reported entities' do
      reviews = double('reviews')
      expect(ReportedEntity).to receive(:find_by_reviews).and_return reviews
      expect(reviews).to receive(:order).and_return reviews
      controller.send :reported_entities_for_reviews, reviews
    end
  end

end
