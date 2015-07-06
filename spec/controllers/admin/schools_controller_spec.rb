require 'spec_helper'

describe Admin::SchoolsController do

  describe '#moderate' do

    let(:school) { FactoryGirl.build(:school) }

    before do
      controller.instance_variable_set(:@school, school)
      allow(controller).to receive(:set_reviews_instance_variable).and_return('blah')
      allow(controller).to receive(:page_title).and_return('blah')
      allow(controller).to receive(:should_paginate_reviews?).and_return('blah')
    end

    subject { controller.moderate }
    it 'should set instance reviews instance variable' do
      expect(controller).to receive(:set_reviews_instance_variable)
      subject
    end

    it 'should set paginate instance variable' do
      expect(controller).to receive(:should_paginate_reviews?)
      subject
    end

    it 'should set page title' do
      expect(controller).to receive(:page_title)
      subject
    end
  end

  describe '#school_reviews' do
    let(:school) { FactoryGirl.build(:school) }
    let(:school_reviews) { FactoryGirl.build_list(:review, 3) }
    before do
      allow(Review).to receive_message_chain(:where, :eager_load, :order).and_return(school_reviews)
    end
    subject { controller.school_reviews(school) }

    context 'without topic parameter' do
      it 'should return an active record relation' do
        expect(Review).to receive_message_chain(:where, :eager_load, :order)
        subject
      end
    end

    context 'with topic parameter' do
      let(:params) { {topic: 'blah'} }
      before do
        allow(controller).to receive(:params).and_return(params)
        allow(school_reviews).to receive(:merge)
      end
      it 'should return an active record relation' do
        expect(Review).to receive_message_chain(:where, :eager_load, :order)
        subject
      end
      it 'should merge reviews for a specific topic' do
        expect(school_reviews).to receive(:merge)
        subject
      end
    end
  end

  describe '#set_reviews_instance_variable' do
    let(:school) { FactoryGirl.build(:school) }
    before { controller.instance_variable_set(:@school, school) }
    subject { controller.set_reviews_instance_variable }

    context 'with a review_id parameter' do
      let(:params) { {review_id: '1'} }
      let(:review) { FactoryGirl.build_list(:review, 1) }
      before do
        allow(controller).to receive(:params).and_return(params)
        allow(Review).to receive(:where).and_return(review)
      end
      it 'should return review matching review_id params' do
        expect(Review).to receive(:where).with({id: '1'})
        subject
      end

    end

    context 'without a review_id parameter' do
      let(:school_reviews) { FactoryGirl.build_list(:review, 3) }
      let(:params_hash) { {} }
      before do
        allow(controller).to receive(:params).and_return(params_hash)
        allow(controller).to receive(:school_reviews).and_return school_reviews
        allow(controller).to receive_message_chain(:apply_scopes, :page, :per, :load).and_return(school_reviews)
      end
      it 'should get all reviews for school' do
        expect(controller).to receive(:school_reviews).with(school)
        subject
      end
      it 'apply moderation scopes to reviews' do
        expect(controller).to receive_message_chain(:apply_scopes, :page, :per, :load)
        subject
      end
    end
  end

  describe '#should_paginate_reviews?' do

    context 'with reviews paginated' do
      let(:school_reviews) { FactoryGirl.build_list(:review, 3) }
      before do
        controller.instance_variable_set(:@reviews, school_reviews)
        allow(school_reviews).to receive(:current_page)
      end
      it 'should return true' do
        expect(controller.should_paginate_reviews?).to be_truthy
      end
    end
    context 'with reviews not paginated' do
      let(:school_reviews) { FactoryGirl.build_list(:review, 1) }
      before do
        controller.instance_variable_set(:@reviews, school_reviews)
      end
      it 'should return false' do
        expect(controller.should_paginate_reviews?).to be_falsey
      end
    end
  end

end
