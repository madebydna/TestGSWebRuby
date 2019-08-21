require 'spec_helper'

describe Admin::ReviewsController do

  it 'should have the right methods' do
    expect(controller).to respond_to :deactivate
    expect(controller).to respond_to :activate
    expect(controller).to respond_to :flag
  end

  describe '#update' do
    before do
      request.env['HTTP_REFERER'] = 'www.greatschools.org/blah'
    end
    after do
      expect(response).to redirect_to request.env['HTTP_REFERER']
    end

    it 'should update the review if one is found' do
      review = FactoryBot.build(:review)
      allow(Review).to receive(:find).and_return(review)
      expect(review).to receive(:update_attributes).and_return true
      post :update, id: 1, review: { comment: 'Foo' }
    end

    it 'should handle update failure by setting flash message' do
      review = FactoryBot.build(:review)
      allow(Review).to receive(:find).and_return(review)
      expect(review).to receive(:update_attributes).and_return false
      expect(controller).to receive(:flash_error)
      post :update, id: 1, review: { comment: 'Foo' }
    end
  end

  describe '#flag' do
    before do
      request.env['HTTP_REFERER'] = 'www.greatschools.org/blah'
    end
    after do
      expect(response).to redirect_to request.env['HTTP_REFERER']
    end

    it 'should flag the review if one is found' do
      allow(controller).to receive(:logged_in?).and_return(true)
      comment = 'foo'
      review_flag = double(ReviewFlag).as_null_object
      review = FactoryBot.build(:review)
      allow(Review).to receive(:find).and_return(review)
      expect(review).to receive(:build_review_flag).with(comment, 'user-reported') {
        review_flag
      }
      expect(review_flag).to receive(:save).and_return(true)
      expect(controller).to receive(:flash_notice)
      post :flag, id: 1, reason: comment
    end

    it 'should handle save failure by setting flash message' do
      allow(controller).to receive(:logged_in?).and_return(true)
      comment = 'foo'
      review_flag = double(ReviewFlag).as_null_object
      review = FactoryBot.build(:review)
      allow(Review).to receive(:find).and_return(review)
      expect(review).to receive(:build_review_flag).with(comment, 'user-reported') {
        review_flag
      }
      expect(review_flag).to receive(:save).and_return(false)
      expect(controller).to receive(:flash_error)
      post :flag, id: 1, reason: comment
    end
  end

  describe '#moderation' do
    let(:school) { FactoryBot.build(:school) }
    let(:flagged_reviews) { FactoryBot.build_list(:review, 3, :flagged) }
    let(:valid_reviews) { FactoryBot.build_list(:review, 3) }
    let(:user) {FactoryBot.build(:user)}

    before do
      allow(controller).to receive(:flagged_reviews).and_return flagged_reviews
      allow(controller).to receive(:find_reviews_by_user).with(user).and_return valid_reviews
      allow(controller).to receive(:find_reviews_flagged_by_user).and_return flagged_reviews
    end

    context 'provided a state and school ID' do
      before do
        expect(School).to receive(:find_by_state_and_id).with('ca', '1').and_return(school)
        allow(controller).to receive(:school_flagged_reviews).and_return(flagged_reviews)
      end

      it 'should look for a school if provided a state and school ID' do
        expect(School).to_not receive(:find_by_state_and_id)
        get :moderation, state: 'ca', school_id: 1
      end

      it 'should expose flagged reviews to the view' do
        get :moderation, state: 'ca', school_id: 1
        expect(assigns[:flagged_reviews]).to eq flagged_reviews
      end
    end

    context 'provided a search string' do

      it 'should look for reviews and flags by user if email is provided' do
        expect(User).to receive(:find_by_email).and_return user
        expect(controller).to receive(:find_reviews_by_user).with(user).and_return valid_reviews
        expect(controller).to receive(:find_reviews_flagged_by_user).and_return flagged_reviews

        get :moderation, review_moderation_search_string: 'someone@domain.com'
      end

    end

  end

  describe '#flagged reviews' do
    let!(:school) { FactoryBot.create(:alameda_high_school) }
    let!(:user) { FactoryBot.create(:verified_user) }
    let!(:non_verified_user) { FactoryBot.create(:new_user, email_verified: false) }
    before do
      controller.instance_variable_set(:@current_user, user)
      allow(controller).to receive(:school_from_params) { school }
    end
    after do
      clean_dbs :gs_schooldb
      clean_models :ca, School
    end
    subject do
      controller.send(:sort_table)
    end

    context 'with flagged reviews for a non-verified user' do
      let!(:flagged_review_for_non_verified_user) do
        FactoryBot.create(:review, :flagged, school: school, user: non_verified_user)
      end

      context 'with a non-flagged inactive review for the same school/user/question' do
        let!(:non_flagged_review) { FactoryBot.create(:review, school: school, user: user) }

        context 'with multiple flagged inactive reviews for the same school/user/question' do
          let!(:reviews) do
            FactoryBot.create_list(:review, 3, :flagged, school: school, user: user)
          end
          before do
            reviews.each do |review|
              review.moderated = true
              review.deactivate
              review.question = ReviewQuestion.first
              review.save
            end
          end

          it 'should only return one review for the given school/user/question group' do
            expect(subject.size).to eq(1)
            groups = subject.group_by { |review| "#{review.member_id} #{review.state} #{review.school_id} #{review.review_question_id} "}
            groups.values.each do |reviews_per_group|
              expect(reviews_per_group.size).to eq(1)
            end
          end

          it 'should only return flagged reviews' do
            subject.each do |review|
              expect(review.flags).to be_present
            end
          end

          it 'should return only reviews for verified users' do
            expect(subject).to_not include(flagged_review_for_non_verified_user)
          end

          it "should preload schools" do
            subject
            fake_class = double.as_null_object
            stub_const('School', fake_class)
            expect(fake_class).to_not receive(:on_db)
            subject.each do |review|
              review.send(:school)
            end
          end

          [:user, :question, :answers].each do |association|
            it "should preload #{association}s" do
              subject
              subject.each do |review|
                expect(review.association(association)).to be_loaded
              end
            end
          end
        end
      end
    end
  end

  shared_context 'with one inactive review' do
    let!(:school) { FactoryBot.create(:alameda_high_school) }
    let!(:review) do
      r = FactoryBot.build(:five_star_review, school: school)
      r.moderated = true
      r.deactivate
      r.save
      r
    end
    after do
      clean_dbs :gs_schooldb
      clean_models :ca, School
    end
  end

  shared_context 'with one active review' do
    let!(:school) { FactoryBot.create(:alameda_high_school) }
    let!(:review) do
      r = FactoryBot.build(:five_star_review, school: school)
      r.moderated = true
      r.activate
      r.save
      r
    end
    after do
      clean_dbs :gs_schooldb
      clean_models :ca, School
    end
  end

  describe '#activate' do
    subject do
      post :activate, id: review.id
      review.reload
    end
    with_shared_context 'with one inactive review' do
      it 'should activate the review' do
        expect{subject}.to change{ review.active }.from(false).to(true)
      end
    end
  end

  describe '#deactivate' do
    let!(:school) { FactoryBot.create(:alameda_high_school) }
    subject do
      post :deactivate, id: review.id
      review.reload
    end
    with_shared_context 'with one active review' do
      it 'should deactivate the review' do
        expect{subject}.to change{ review.active }.from(true).to(false)
      end
    end
  end

  describe '#set_pagination_data_on_reviews' do
    before do
      allow(controller).to receive(:total_number_of_reviews_to_moderate) { 101 }
      stub_const('Admin::ReviewsController::MODERATION_LIST_PAGE_SIZE', 100)
    end
    it 'should define #total_pages on input and it should return 2' do
      stubbed_reviews = Object.new
      expect do
        controller.set_pagination_data_on_reviews(stubbed_reviews)
      end.to change { stubbed_reviews.try(:total_pages) }.from(nil).to(2)
    end
  end



end
