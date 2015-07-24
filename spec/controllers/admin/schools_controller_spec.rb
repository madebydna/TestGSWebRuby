require 'spec_helper'

describe Admin::SchoolsController do

  describe '#moderate' do

    let(:school) { FactoryGirl.create(:school) }
    let!(:reviews) { FactoryGirl.create_list(:review, 3, school_id: school.id) }

    before { controller.instance_variable_set(:@school, school) }
    after do
      clean_models(:gs_schooldb, Review, ReviewTopic, ReviewQuestion, User)
      clean_models(:ca, School)
    end

    subject { controller }

    context 'with a review_id parameter' do
      let(:params) { {review_id: reviews.first.id} }
      before do 
        allow(subject).to receive(:params).and_return(params)
      end

      it 'should set instance variable for reviews' do
        subject.moderate
        expect(subject.instance_variable_defined?('@reviews')).to be_truthy
      end

      it 'should set reviews instance variable to one review that matches the review_id parameter' do
        subject.moderate
        expect(subject.instance_variable_get('@reviews').count).to eq(1)
        expect(subject.instance_variable_get('@reviews').first).to eq(reviews.first)
      end

      it 'the reviews instance variable should not respond to pagination methods' do
        subject.moderate
        expect(subject.instance_variable_get('@reviews').respond_to?(:current_page)).to be_falsey
      end

      it 'should set the paginate instance variable to false' do
        subject.moderate
        expect(subject.instance_variable_defined?('@paginate')).to be_truthy
        expect(subject.instance_variable_get('@paginate')).to be_falsey
      end

      it 'should set the meta_tags_title to one review page title' do
        expect(controller).to receive(:set_meta_tags).with(title: 'Reviews moderation - review')
        subject.moderate
      end

    end

    context 'without parameter' do
      it 'should set instance variable for reviews' do
        subject.moderate
        expect(subject.instance_variable_defined?('@reviews')).to be_truthy
      end

      it 'should set reviews instance variable to equal all the reviews for the schools' do
        subject.moderate
        expect(subject.instance_variable_get('@reviews').count).to eq(reviews.count)
        expect(subject.instance_variable_get('@reviews').to_a.sort).to eq(reviews.sort)
      end

      it 'the reviews instance variable should respond to pagination methods' do
        subject.moderate
        expect(subject.instance_variable_get('@reviews').respond_to?(:current_page)).to be_truthy
      end

      it 'should set the paginate instance variable to true' do
        subject.moderate
        expect(subject.instance_variable_defined?('@paginate')).to be_truthy
        expect(subject.instance_variable_get('@paginate')).to be_truthy
      end
    end

      it 'should set the meta_tags_title to moderation school page title' do
        expect(subject).to receive(:set_meta_tags).with(title: 'Reviews moderation - school')
        subject.moderate
      end
  end

end
