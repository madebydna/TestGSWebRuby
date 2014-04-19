require 'spec_helper'
require 'controllers/concerns/review_controller_concerns_spec'

describe ReviewsController do
  let(:current_user) { FactoryGirl.build(:user) }

  it_should_behave_like 'a controller that can save a review'

  describe '#report' do

    it 'should flash error and redirect back if all params not provided' do
      request.env['HTTP_REFERER'] = 'www.greatschools.org/blah'
      expect(controller).to_not receive :report_review_and_redirect
      post :report, reported_entity_id: 1
      expect(response).to redirect_to request.env['HTTP_REFERER']
    end

    it 'should save deferred action if not logged in' do
      controller.stub(:logged_in?).and_return false
      expect(controller).to_not receive :report_review_and_redirect
      post :report, reported_entity_id: 1, reported_entity: { reason: 'any reason' }
      expect(response).to redirect_to controller.signin_url
    end

    it 'should report review and redirect' do
      controller.stub(:logged_in?).and_return true
      controller.stub(:report_review_and_redirect) { controller.redirect_to 'blah' }
      post :report, reported_entity_id: 1, reported_entity: { reason: 'any reason' }
      expect(response).to redirect_to 'blah'
    end
  end

  describe '#report_review_and_redirect' do

    before do
      controller.stub(:current_user).and_return current_user
      controller.stub(:logged_in?).and_return(true)
      @review_id = 1
      @reason = 'any reason'
      @reviews_page = 'reviews_page'
      controller.stub(:reviews_page_for_last_school).and_return @reviews_page
      expect(controller).to receive(:redirect_to).with(@reviews_page)
    end

    it 'should do nothing if not logged in' do
      controller.stub(:logged_in?).and_return(false)
      expect(SchoolRating).to_not receive :find
      controller.send :report_review_and_redirect, review_id: @review_id, reason: @reason
    end

    it 'should set flash error if finding review throws error' do
      SchoolRating.stub(:find).and_raise('error')
      expect(controller).to receive :flash_error
      controller.send :report_review_and_redirect, review_id: @review_id, reason: @reason
    end

    it 'should bail and redirect if reported review not found' do
      expect(ReportedEntity).to_not receive(:from_review)
      SchoolRating.stub(:find).and_return nil
      controller.send :report_review_and_redirect, review_id: @review_id, reason: @reason
    end

    it 'should save reported entity if review exists' do
      school_rating = SchoolRating.new
      SchoolRating.stub(:find).and_return school_rating
      expect(ReportedEntity).to receive(:from_review)
        .with(school_rating, @reason).and_return(
          double(save: true, :'reporter_id=' => true)
        )
      expect(controller).to receive(:flash_notice)
        .with I18n.t('actions.report_review.reported')
      controller.send :report_review_and_redirect,
                      review_id: @review_id,
                      reason: @reason
    end

    it 'should flash error message if review can\'t be saved' do
      school_rating = SchoolRating.new
      SchoolRating.stub(:find).and_return school_rating
      expect(ReportedEntity).to receive(:from_review)
        .with(school_rating, @reason).and_return(
          double(save: false, :'reporter_id=' => true)
        )
      expect(controller).to receive(:flash_error)
        .with I18n.t('actions.generic_error')
      controller.send :report_review_and_redirect,
                      review_id: @review_id,
                      reason: @reason
    end

    it 'should flash error message if an exception occurs' do
      school_rating = SchoolRating.new
      SchoolRating.stub(:find).and_return school_rating
      expect(ReportedEntity).to receive(:from_review).and_raise 'error'
      expect(controller).to receive(:flash_error)
        .with I18n.t('actions.generic_error')
      controller.send :report_review_and_redirect,
                      review_id: @review_id,
                      reason: @reason
    end
  end


end