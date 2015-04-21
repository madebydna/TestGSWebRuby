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
      allow(controller).to receive(:find_school).and_return(school)
      allow(PageConfig).to receive(:new).and_return(page_config)
      allow(page_config).to receive(:name).and_return('reviews')
    end

    it 'should set the list of reviews' do
      reviews = FactoryGirl.build_list(:review, 2)
      school_reviews = double('SchoolReviews', reviews: reviews).as_null_object
      expect(HelpfulReview).to receive(:helpful_counts).with(school_reviews).and_return({})
      expect(SchoolReviews).to receive(:new).with(school).and_return(school_reviews)
      get 'reviews', controller.view_context.school_params(school)
      expect(assigns[:school_reviews]).to eq(school_reviews)
    end

    it 'should look up the correct school' do
      get 'reviews', controller.view_context.school_params(school)
      expect(assigns[:school]).to eq(school)
    end
  end

end
