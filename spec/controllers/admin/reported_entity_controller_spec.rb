require 'spec_helper'

describe Admin::ReportedEntityController do
  after do
    clean_models ReportedEntity
  end

  it { is_expected.to respond_to(:deactivate) }

  describe '#deactivate' do
    let(:reported_entity) { FactoryGirl.create(:reported_review) }

    it 'should read the reported entity object' do
      expect(ReportedEntity).to receive(:find).with reported_entity.id
      get :deactivate, id: reported_entity.id
    end

    it 'should deactivate the reported entity' do
      expect(ReportedEntity).to receive(:find).and_return reported_entity
      get :deactivate, id: reported_entity.id
      expect(reported_entity).to be_inactive
    end

    context 'reported entity disabled' do
      subject(:result) { get :deactivate, id: reported_entity.id }

      it 'controller should set a flash notice' do
        expect(controller).to receive(:flash_notice)
        result
      end

      it 'should redirect to the review moderation list' do
        expect(result).to redirect_to moderation_admin_reviews_path
      end
    end

    context 'reported entity not found' do
      subject(:result) { get :deactivate, id: 'sldfjk' }

      it 'controller should set a flash error' do
        expect(controller).to receive(:flash_error)
        result
      end

      it 'should redirect to the review moderation list' do
        expect(result).to redirect_to moderation_admin_reviews_path
      end
    end

    context 'reported entity cannot be saved' do
      before(:each) do
        ReportedEntity.any_instance.stub(:save).and_return false
      end

      subject(:result) { get :deactivate, id: reported_entity.id }

      it 'controller should set a flash error' do
        expect(controller).to receive(:flash_error)
        result
      end

      it 'should redirect to the review moderation list' do
        expect(result).to redirect_to moderation_admin_reviews_path
      end
    end
  end

end