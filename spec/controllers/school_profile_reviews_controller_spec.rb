require 'spec_helper'

describe SchoolProfileReviewsController do
  let(:school) { FactoryGirl.build(:school) }
  let(:page) { FactoryGirl.build(:page) }
  let(:page_config) { double(PageConfig) }

  it 'should have only one action' do
    expect(controller.action_methods.size).to eq(1)
    expect(controller.action_methods - ['reviews']).to eq(Set.new)
  end

  describe 'GET reviews' do
    before do
      allow(controller).to receive(:find_school).and_return(school)
      allow(PageConfig).to receive(:new).and_return(page_config)
      allow(page_config).to receive(:name).and_return('reviews')
    end

    it 'should set the list of reviews' do
      reviews = [ instance_double(SchoolRating) ]
      expect(HelpfulReview).to receive(:helpful_counts).with(reviews).and_return({})
      expect(school).to receive(:reviews_filter).and_return(reviews)
      get 'reviews', controller.view_context.school_params(school)
      expect(assigns[:school_reviews]).to eq(reviews)
    end

    it 'should look up the correct school' do
      get 'reviews', controller.view_context.school_params(school)
      expect(assigns[:school]).to eq(school)
    end

    it 'should set data needed for header' do
      get 'reviews', controller.view_context.school_params(school)
      expect(assigns[:school_reviews_global]).to be_present
    end
  end

end
