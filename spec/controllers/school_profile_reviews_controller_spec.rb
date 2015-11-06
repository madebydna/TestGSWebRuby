require 'spec_helper'

describe SchoolProfileReviewsController do
  let(:school) { FactoryGirl.build(:school) }
  let(:page) { FactoryGirl.build(:page) }
  let(:page_config) { double(PageConfig) }

  it 'should have only specified actions' do
    pending('TODO: add protected keyword to ApplicationHelper, UpdateQueueConcerns and SavedSearchesConcerns and fix code / specs')
    fail
    puts controller.action_methods.to_a.join(', ')
    expect(controller.action_methods.size).to eq(2)
    expect(controller.action_methods - ['reviews', 'create']).to eq(Set.new)
  end

  describe 'GET reviews' do
    before do
      stub_const('SchoolProfileReviewsController::MAX_NUMBER_OF_REVIEWS_FOR_OVERVIEW_REL_CANONICAL', 3)
      allow(controller).to receive(:find_school).and_return(school)
      allow(PageConfig).to receive(:new).and_return(page_config)
      allow(page_config).to receive(:name).and_return('reviews')
    end

    it 'should set the list of reviews' do
      reviews = FactoryGirl.build_list(:review, 2)
      school_reviews = double('SchoolReviews', reviews: reviews).as_null_object
      expect(SchoolReviews).to receive(:new).and_return(school_reviews)
      get 'reviews', controller.view_context.school_params(school)
      expect(assigns[:school_reviews]).to eq(school_reviews)
    end

    it 'should look up the correct school' do
      get 'reviews', controller.view_context.school_params(school)
      expect(assigns[:school]).to eq(school)
    end

    it 'should set canonical url to profile page when less than min reviews' do
      school_reviews = double('SchoolReviews', number_of_reviews_with_comments: 2).as_null_object
      expect(SchoolReviews).to receive(:new).and_return(school_reviews)
      get 'reviews', controller.view_context.school_params(school)
      expect(assigns[:canonical_url]).to eq(school_url(school))
    end

    it 'should set canonical url to profile page when euqal to  min reviews' do
      school_reviews = double('SchoolReviews', number_of_reviews_with_comments: 3).as_null_object
      expect(SchoolReviews).to receive(:new).and_return(school_reviews)
      get 'reviews', controller.view_context.school_params(school)
      expect(assigns[:canonical_url]).to eq(school_url(school))
    end

    it 'should set canonical url to reviews page when more than max reviews for rel canonical' do
      school_reviews = double('SchoolReviews', number_of_reviews_with_comments: 4).as_null_object
      expect(SchoolReviews).to receive(:new).and_return(school_reviews)
      get 'reviews', controller.view_context.school_params(school)
      expect(assigns[:canonical_url]).to eq(school_reviews_url(school))
    end 

  end

  describe '#create' do
    let(:school) { FactoryGirl.create(:alameda_high_school) }
    let(:review_params) do
      {
        school_id: school.id.to_s,
        state: 'CA',
        review_question_id: '1',
        comment: 'test ' * 15,
        answers_attributes: {
          '1' => {
            review_id: '1',
            answer_value: '5'
          }
        }
      }
    end
    let(:params) do
      controller.view_context.school_params(school).merge(review: review_params)
    end
    let(:post_a_review) do
      xhr :post, :create, params
    end

    context 'when not logged in' do
      after do
        clean_models School
      end

      it 'should save a deferred action' do
        expect(controller).to receive(:save_deferred_action).with(:save_review_deferred, review_params)
        post_a_review
      end

      it 'should not save any review' do
        post_a_review
        expect(Review.count).to eq(0)
      end

      it 'should return a redirect url' do
        post_a_review
        hash = JSON.parse(response.body)
        expect(hash['redirect_url']).to eq(controller.view_context.join_url)
      end
    end

    shared_context 'when logged in as a parent' do
      let!(:user) { FactoryGirl.create(:verified_user) }
      let!(:school_user) { FactoryGirl.create(:parent_school_user, school: school, user: user) }
      before do
        controller.instance_variable_set(:@current_user, user)
      end
      after do
        clean_models School
        clean_dbs :gs_schooldb
      end
    end

    shared_context 'when logged in as an osp approved principal' do
      let!(:user) { FactoryGirl.create(:verified_user) }
      let!(:school_user) { FactoryGirl.create(:principal_school_user, school: school, user: user) }
      before do
        controller.instance_variable_set(:@current_user, user)
        allow_any_instance_of(SchoolUser).to receive(:approved_osp_user?).and_return(true)
      end
      after do
        clean_models School
        clean_dbs :gs_schooldb
      end
    end

    shared_context 'when logged in as a non-approved principal' do
      let!(:user) { FactoryGirl.create(:verified_user) }
      let!(:school_user) { FactoryGirl.create(:principal_school_user, school: school, user: user) }
      before do
        controller.instance_variable_set(:@current_user, user)
        allow_any_instance_of(SchoolUser).to receive(:approved_osp_user?).and_return(false)
      end
      after do
        clean_models School
        clean_dbs :gs_schooldb
      end
    end

    shared_context 'when logged in as a student' do
      let!(:user) { FactoryGirl.create(:verified_user) }
      let!(:school_user) { FactoryGirl.create(:student_school_user, school: school, user: user) }
      before do
        controller.instance_variable_set(:@current_user, user)
      end
      after do
        clean_models School
        clean_dbs :gs_schooldb
      end
    end

    [
      'when logged in as a non-approved principal',
      'when logged in as a student'
    ].each do |context|
      with_shared_context context do
        it 'should create an inactive review' do
          post_a_review
          expect(Review.count).to eq(1)
          expect(Review.first).to be_inactive
        end

        context 'when user had a previous active review for same topic' do
          let!(:review) { FactoryGirl.create(:five_star_review, school: school, user: user, review_question_id: 1) }
          before do
            review.moderated = true
            review.activate
            review.save
          end

          it 'should deactivate the old review' do
            post_a_review
            review.reload
            expect(review).to be_inactive
            expect(Review.count).to eq(2)
          end

          it 'should write a new inactive review' do
            post_a_review
            review.reload
            expect(Review.count).to eq(2)
            expect((Review.all - [review]).first).to be_inactive
          end
        end
      end
    end

    [
      'when logged in as an osp approved principal',
      'when logged in as a parent'
    ].each do |context|
      with_shared_context context do
        it 'should create an active review' do
          post_a_review
          expect(Review.count).to eq(1)
          expect(Review.first).to be_active
        end

        context 'when user had a previous active review for same topic' do
          let!(:review) { FactoryGirl.create(:five_star_review, school: school, user: user, review_question_id: 1) }
          before do
            review.moderated = true
            review.activate
            review.save
          end

          it 'should deactivate the old review' do
            post_a_review
            review.reload
            expect(review).to be_inactive
            expect(Review.count).to eq(2)
            expect(Review.active.count).to eq(1)
          end

          it 'should write a new active review' do
            post_a_review
            review.reload
            expect(Review.count).to eq(2)
            expect((Review.all - [review]).first).to be_active
          end
        end
      end
    end
  end

  describe '#first_topic_id_to_show' do
    context 'when @school_user is set' do
      let(:school) { FactoryGirl.build(:alameda_high_school) }
      let(:user) { FactoryGirl.build(:verified_user) }
      let(:school_user) { FactoryGirl.build(:parent_school_user, school: school, user: user) }
      let(:honesty_topic) { FactoryGirl.build(:honesty_topic) }
      let(:overall_topic) { FactoryGirl.build(:overall_topic) }
      before do
        controller.instance_variable_set(:@school_user, school_user)
        allow(school_user).to receive(:first_unanswered_topic).and_return(honesty_topic)
      end
      it 'should return id for user\'s first unanswered topic' do
        expect(controller.first_topic_id_to_show).to eq(honesty_topic.id)
      end
    end
    context 'when @school_user is not set' do
      it 'should return id for Teachers topic' do
        expect(ReviewTopic).to receive(:find_id_by_name).with(ReviewTopic::OVERALL)
        controller.first_topic_id_to_show
      end
    end
  end
end
