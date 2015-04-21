require 'spec_helper'

describe ReviewControllerConcerns::ReviewParams do
  let(:user) { FactoryGirl.build(:verified_user) }
  let(:review_params) do
    {
      state: 'ca',
      school_id: 1,
      review_question_id: 1
    }
  end
  let(:params_object) { ReviewControllerConcerns::ReviewParams.new(review_params, user) }
  subject { params_object }
  it { is_expected.to be_a(ReviewControllerConcerns::ReviewParams) }

  describe '#save_new_review' do
    subject { params_object.save_new_review }
    before do
      allow(params_object).to receive(:handle_save) { |review| review }
    end

    it 'should save a review' do
      expect(params_object).to receive(:handle_save).with(kind_of(Review)) { |review| review }
      review, errors = subject
      expect(review).to be_a(Review)
      expect(errors).to be_nil
    end

    it 'should return any errors' do
      expect(params_object).to receive(:handle_save).with(kind_of(Review)) { |review| [nil, 'An error message'] }
      review, errors = subject
      expect(review).to be_nil
      expect(errors).to eq('An error message')
    end

    it 'should set the member_id on review' do
      user.id = 999
      review, errors = subject
      expect(review.member_id).to eq(999)
    end

    it 'should set the comment on review' do
      review_params[:comment] = 'foo bar baz'
      review, errors = subject
      expect(review.comment).to eq('foo bar baz')
    end

    context 'only when the school is found in the database' do
      let(:school) { FactoryGirl.create(:alameda_high_school) }
      after do
        clean_models School
      end
      it 'should set the school id and state on review' do
        review_params[:school_id] = school.id
        review_params[:state] = school.state
        review, errors = subject
        expect(review.school_id).to eq(school.id)
        expect(review.state).to eq(school.state)
      end
    end

    context 'when the school is not found in the database' do
      it 'should NOT set the school id and state on review' do
        review_params[:school_id] = 999
        review_params[:state] = 'ca'
        review, errors = subject
        expect(review.school_id).to eq(nil)
        expect(review.state).to eq(nil)
      end
    end
  end

  describe '#handle_save' do
    let(:review) { FactoryGirl.build(:review) }
    subject { params_object.handle_save(review) }
    it 'should not try to save the review if there are errors with parameters' do
      review_params[:school_id] = nil
      expect(review).to_not receive(:save)
      subject
    end

    it 'should return any parameter errors' do
      review_params[:school_id] = nil
      review, errors = subject
      expect(errors).to include 'Specified school was not found'
    end

    it 'should save a valid review' do
      allow(params_object).to receive(:school).and_return(FactoryGirl.build(:school))
      expect(review).to receive(:save)
      subject
    end

    it 'should return errors if review fails to save' do
      allow(params_object).to receive(:school).and_return(FactoryGirl.build(:school))
      expect(review).to receive(:save).and_return(false)
      allow(review).to receive(:errors).and_return(double(full_messages: ['foo bar']))
      review, errors = subject
      expect(errors).to include 'foo bar'
    end
  end

  describe '#existing_review' do
    let(:users) { FactoryGirl.create_list(:verified_user, 5) }
    let(:user) { users[3] }
    let(:schools) { FactoryGirl.create_list(:a_high_school, 5) }
    let(:reviews) { FactoryGirl.create_list(:review, 5) }
    let(:review_questions) { FactoryGirl.create_list(:review_question, 5) }
    let(:review_params) do
      {
        state: schools[3].state,
        school_id: schools[3].id,
        question_id: review_questions[3].id
      }
    end
    before do
      reviews[4].question = review_questions[3]
      reviews[4].user = user
      reviews[4].school = schools[3]
      reviews[4].save
    end
    after do
      clean_models User, School, Review, ReviewQuestion, ReviewTopic
    end

    it 'should return only the review for current user, given school, matching review question' do
      expect(subject.existing_review).to eq(reviews[4])
    end
  end


  describe '#save_review_and_redirect' do
    let(:controller) { (Class.new { include ReviewControllerConcerns }).new }
    let(:review_params) { double }
    let(:review) { FactoryGirl.build(:review) }
    before do
      allow(controller).to receive(:t) { |s| I18n.t(s) }
      allow(controller).to receive(:set_omniture_events_in_cookie)
      allow(controller).to receive(:set_omniture_sprops_in_cookie)
      allow(controller).to receive(:flash_notice)
      allow(controller).to receive(:reviews_page_for_last_school) { '/reviewspage' }

      allow(controller).to receive(:build_review_params).and_return(review_params)
    end
    subject { controller.send :save_review_and_redirect, review_params }

    context 'when review saved successfully' do
      before(:each) do
        allow(review_params).to receive(:save_new_review).and_return([review, nil])
      end

      it 'should set omniture data if review active' do
        allow(review).to receive(:active?).and_return(true)
        expect(controller).to receive :set_omniture_events_in_cookie
        expect(controller).to receive :set_omniture_sprops_in_cookie
        expect(controller).to receive(:redirect_to).with '/reviewspage'
        subject
      end

      it "should flash actions.review.pending_moderation message if review is not active" do
        allow(review).to receive(:active?).and_return(false)
        expect(controller).to receive(:flash_notice).with I18n.t('actions.review.pending_moderation')
        expect(controller).to receive(:redirect_to).with '/reviewspage'
        subject
      end

      it 'should flash actions.review.activated message if review is active' do
        allow(review).to receive(:active?).and_return(true)
        expect(controller).to receive(:flash_notice).with I18n.t('actions.review.activated')
        expect(controller).to receive(:redirect_to).with '/reviewspage'
        subject
      end
    end

    context 'when error saving review' do
      before(:each) do
        allow(review_params).to receive(:save_new_review).and_return([nil, 'error message'])
      end

      it 'should flash an error message' do
        expect(controller).to receive(:flash_error).with('error message')
        expect(controller).to receive(:redirect_to).with '/reviewspage'
        subject
      end
    end
  end

end