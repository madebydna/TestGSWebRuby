require 'spec_helper'

shared_examples_for 'a controller that can save a review' do

	describe '#save_review' do
    let(:current_user) { FactoryGirl.build(:user) }
    let(:existing_review) { FactoryGirl.build(:school_rating) }
    let(:review_params) {
      {
        school_id: 1,
        state: 'ca',
        review_text: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit.
                      Minima, nihil delectus fugiat dolorum esse error
                      doloremque optio a blanditiis adipisci quaerat fugit
                      voluptas est officia ipsam. Quia recusandae omnis
                      animi.',
        overall: 5,
        affiliation: 'student'
      }
    }

    before(:each) do
      allow(controller).to receive(:current_user).and_return current_user
      allow(controller).to receive(:review_from_params).and_return FactoryGirl.
        build(:school_rating)
    end

    it 'should fail gracefully with error if given bad arguments' do
      review, error = controller.send :save_review, current_user, {}
      expect(error).to be_present
    end

    context 'with a user with no existing review' do
      before(:each) do
        allow_any_instance_of(SchoolRating).to receive(:save).and_return true
        allow(controller).to receive(:update_existing_review).and_return nil, nil
      end

      it 'should successfully save a review' do
        expect_any_instance_of(SchoolRating).to receive(:save)
        controller.send :save_review, current_user, review_params
      end

      it 'should return the saved review' do
        review, error = controller.send :save_review,
                                        current_user,
                                        review_params
        expect(review).to be_a(SchoolRating)
      end

      it 'should not return any error' do
        review, error = controller.send :save_review,
                                        current_user,
                                        review_params
        expect(error).to be_nil
      end

      it 'should set current_user onto review' do
        review, error = controller.send :save_review,
                                        current_user,
                                        review_params
        expect(review.user).to eq current_user
      end

      it 'should return an error if object can\'t be saved' do
        allow_any_instance_of(SchoolRating).to receive(:save).and_return false
        allow_any_instance_of(SchoolRating).to receive(:errors) {
          double(full_messages: ['error message'])
        }
        review, error = controller.send :save_review,
                                        current_user,
                                        review_params
        expect(error).to eq 'error message'
      end

      it 'should return an error if something else goes wrong' do
        allow(controller).to receive(:review_from_params).and_raise(RuntimeError)

        review, error = controller.send :save_review,
                                        current_user,
                                        review_params
        expect(error).to be_present
      end
    end

    context 'with a user with an existing review' do
      before(:each) do
        allow(controller).to receive(:update_existing_review).and_return existing_review,
                                                            nil
      end

      it 'should return the updated review' do
        review, error = controller.send :save_review,
                                        current_user,
                                        review_params
        expect(review).to eq existing_review
      end
    end

	end

  describe '#update_existing_review' do
    let(:current_user) { FactoryGirl.build(:user) }
    let(:existing_review) { FactoryGirl.build(:school_rating) }
    let(:review_params) {
      {
        school_id: 1,
        state: 'ca',
        review_text: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit.
                      Minima, nihil delectus fugiat dolorum esse error
                      doloremque optio a blanditiis adipisci quaerat fugit
                      voluptas est officia ipsam. Quia recusandae omnis
                      animi.',
        overall: 5,
        affiliation: 'student'
      }
    }

    before(:each) do
      allow(controller).to receive(:current_user).and_return current_user
      allow(controller).to receive(:review_from_params).and_return FactoryGirl.
        build(:school_rating)
    end

    it 'should fail gracefully with error if given bad arguments' do
      review, error = controller.send :save_review, current_user, {}
      expect(error).to be_present
    end

    context 'with a user with no existing review' do
      before(:each) do
        allow(current_user).to receive(:reviews_for_school).and_return []
      end

      it 'should return nil review and nil error' do
        review, error = controller.send :update_existing_review,
                                        current_user,
                                        review_params
        expect(review).to be_nil
        expect(error).to be_nil
      end
    end

    context 'with a user with one existing review' do
      before(:each) do
        allow(current_user).to receive(:reviews_for_school).and_return [ existing_review ]
      end

      it 'should update and return the review' do
        expect(existing_review).to receive(:update_attributes).and_return true
        review, error = controller.send :update_existing_review,
                                        current_user,
                                        review_params
        expect(review).to be(existing_review)
        expect(error).to be_nil
      end

      it 'should return an error if review cannot be updated' do
        allow(existing_review).to receive(:errors) {
          double(full_messages: ['error message'])
        }
        expect(existing_review).to receive(:update_attributes).
          and_return false

        review, error = controller.send :update_existing_review,
                                        current_user,
                                        review_params
        expect(error).to eq 'error message'
      end

      it 'should return an error if something else goes wrong' do
        allow(controller).to receive(:review_from_params).and_raise(RuntimeError)

        review, error = controller.send :update_existing_review,
                                        current_user,
                                        review_params
        expect(error).to be_present
      end
    end
  end

  describe '#review_from_params' do
    let(:school) { FactoryGirl.build(:school) }
    let(:review_params) {
      {
        school_id: 1,
        state: 'ca',
        review_text: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit.
                      Minima, nihil delectus fugiat dolorum esse error
                      doloremque optio a blanditiis adipisci quaerat fugit
                      voluptas est officia ipsam. Quia recusandae omnis
                      animi.',
        overall: 5,
        affiliation: 'student'
      }
    }

    before(:each) do
      allow(School).to receive(:find_by_state_and_id).and_return school
    end

    it 'should return a review' do
      expect(controller.send :review_from_params, review_params).
        to be_a(SchoolRating)
    end

    it 'should return nil if invalid params supplied' do
      expect(controller.send :review_from_params,
                              review_params.except(:school_id)).to be_nil
      expect(controller.send :review_from_params,
                              review_params.except(:state)).to be_nil
      expect(controller.send :review_from_params, nil).to be_nil
      expect(controller.send :review_from_params, {}).to be_nil
    end

    it 'should set the rating on the p_overall attribute for preschools' do
      school.level_code = 'p'
      review = controller.send :review_from_params, review_params
      expect(review.p_overall).to eq 5
    end

    it 'should set the rating on the overall attribute for preschools' do
      review = controller.send :review_from_params, review_params
      expect(review.overall).to eq 5
    end
  end

  describe '#save_review_and_redirect' do
    let(:review_params) {
      {
        school_id: 1,
        state: 'ca',
        review_text: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit.
                      Minima, nihil delectus fugiat dolorum esse error
                      doloremque optio a blanditiis adipisci quaerat fugit
                      voluptas est officia ipsam. Quia recusandae omnis
                      animi.',
        overall: 5,
        affiliation: 'student'
      }
    }
    let(:review) { FactoryGirl.build(:school_rating) }

    context 'when review saved successfully' do
      before(:each) do
        allow(controller).to receive(:save_review).and_return [ review, nil ]
        allow(controller).to receive(:reviews_page_for_last_school) { '/reviewspage' }
      end

      it 'should set omniture data if review published' do
        review.status = 'p'
        expect(controller).to receive :set_omniture_events_in_cookie
        expect(controller).to receive :set_omniture_sprops_in_cookie
        expect(controller).to receive(:redirect_to).with '/reviewspage'
        controller.send :save_review_and_redirect, review_params
      end

      ['u', 'pu', 'h', 'ph', 'd', 'pd'].each do |status|
        it "should flash actions.review.pending_moderation message if review status is #{status}" do
          review.status = status
          expect(controller).to receive(:flash_notice)
            .with I18n.t('actions.review.pending_moderation')
          expect(controller).to receive(:redirect_to).with '/reviewspage'
          controller.send :save_review_and_redirect, review_params
        end
      end

      it 'should flash actions.review.activated message if review is published' do
        review.status = 'p'
        expect(controller).to receive(:flash_notice)
          .with I18n.t('actions.review.activated')
        expect(controller).to receive(:redirect_to).with '/reviewspage'
        controller.send :save_review_and_redirect, review_params
      end
    end

    context 'when error saving review' do
      before(:each) do
        allow(controller).to receive(:save_review).and_return [ nil, 'error message' ]
        allow(controller).to receive(:review_form_for_last_school) { '/reviewform' }
      end

      it 'should flash an error message' do
        expect(controller).to receive(:flash_error).with('error message')
        expect(controller).to receive(:redirect_to).with '/reviewform'
        controller.send :save_review_and_redirect, review_params
      end
    end
  end
end
