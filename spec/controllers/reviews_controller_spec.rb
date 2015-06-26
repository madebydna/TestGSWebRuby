require 'spec_helper'

describe ReviewsController do
  let(:current_user) { FactoryGirl.build(:user) }

  describe '#flag' do
    it 'should flash error and redirect back if all params not provided' do
      request.env['HTTP_REFERER'] = 'www.greatschools.org/blah'
      expect(controller).to_not receive :flag_review_and_redirect
      put :flag, id: 1
      expect(response).to redirect_to request.env['HTTP_REFERER']
    end

    it 'should save deferred action if not logged in' do
      allow(controller).to receive(:logged_in?).and_return false
      allow(controller).to receive(:current_user).and_return current_user
      allow(current_user).to receive(:provisional?).and_return false
      expect(controller).to_not receive :flag_review_and_redirect
      put :flag, id: 1, review_flag: { comment: 'any reason' }
      expect(response).to redirect_to controller.signin_url
    end

    it 'should flash error, save deferred action and redirect back if logged in and provisional' do
      request.env['HTTP_REFERER'] = 'www.greatschools.org/blah'
      allow(controller).to receive(:logged_in?).and_return true
      allow(controller).to receive(:current_user).and_return current_user
      allow(current_user).to receive(:provisional?).and_return true
      expect(controller).to_not receive :flag_review_and_redirect
      put :flag, id: 1, review_flag: { comment: 'any reason' }
      expect(response).to redirect_to request.env['HTTP_REFERER']
    end

    it 'should report review and redirect' do
      allow(controller).to receive(:current_user).and_return current_user
      allow(current_user).to receive(:provisional?).and_return false
      allow(controller).to receive(:logged_in?).and_return true
      allow(controller).to receive(:flag_review_and_redirect) { controller.redirect_to 'blah' }
      put :flag, id: 1, review_flag: { comment: 'any reason' }
      expect(response).to redirect_to 'blah'
    end
  end

  describe '#flag_review_and_redirect' do

    before do
      allow(controller).to receive(:current_user).and_return current_user
      allow(controller).to receive(:logged_in?).and_return(true)
      @review_id = 1
      @comment = 'any comment'
      @reviews_page = 'reviews_page'
      allow(controller).to receive(:reviews_page_for_last_school).and_return @reviews_page
      expect(controller).to receive(:redirect_to).with(@reviews_page)
    end

    it 'should do nothing if not logged in' do
      allow(controller).to receive(:logged_in?).and_return(false)
      expect(Review).to_not receive :find
      controller.send :flag_review_and_redirect, review_id: @review_id, comment: @comment
    end

    it 'should set flash error if finding review throws error' do
      allow(Review).to receive(:find).and_raise('error')
      expect(controller).to receive :flash_error
      controller.send :flag_review_and_redirect, review_id: @review_id, comment: @comment
    end

    it 'should bail and redirect if flagged review not found' do
      allow(Review).to receive(:find).and_return nil
      controller.send :flag_review_and_redirect, review_id: @review_id, comment: @comment
    end

    it 'should save review flag if review exists' do
      review = Review.new
      allow(Review).to receive(:find).and_return review
      expect(review).to receive(:build_review_flag).with(@comment, ReviewFlag::USER_REPORTED) .and_return(
                                 double(save: true, :'user=' => true)
                               )
      expect(controller).to receive(:flash_notice)
                              .with I18n.t('actions.report_review.reported')
      controller.send :flag_review_and_redirect,
                      review_id: @review_id,
                      comment: @comment
    end

    it 'should flash error message if review can\'t be saved' do
      review = Review.new
      allow(Review).to receive(:find).and_return review
      review_flag = double(save: false, :'user=' => true)
      allow(review_flag).to receive(:attributes).and_return({})
      allow(review_flag).to receive(:errors).and_return([])
      expect(review).to receive(:build_review_flag).with(@comment, ReviewFlag::USER_REPORTED).and_return(review_flag)
      expect(controller).to receive(:flash_error).with I18n.t('actions.generic_error')
      controller.send :flag_review_and_redirect,
                      review_id: @review_id,
                      comment: @comment
    end

    it 'should flash error message if an exception occurs' do
      review = Review.new
      allow(Review).to receive(:find).and_return review
      expect(review).to receive(:build_review_flag).and_raise 'error'
      expect(controller).to receive(:flash_error)
                              .with I18n.t('actions.generic_error')
      controller.send :flag_review_and_redirect,
                      review_id: @review_id,
                      comment: @comment
    end
  end

end
