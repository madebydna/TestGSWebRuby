require 'spec_helper'

describe DataLayerConcerns do
  let(:controller) { FakeController.new }
  let(:user) {FactoryGirl.create(:user)}

  before(:all) do
    class FakeController < ActionController::Base
      include DataLayerConcerns
    end
  end
  after(:all) do
    Object.send :remove_const, :FakeController
    clean_models User
  end

  describe '#add_user_id_to_gtm_data_layer' do
    before do
      controller.request = request
      controller.gon.data_layer_hash = {}
      controller.gon.data_layer_hash
    end
    subject { controller.gon.data_layer_hash }

    context 'with a signed in user' do
      before do
        allow(controller).to receive(:current_user).and_return(user)
        controller.send(:add_user_id_to_gtm_data_layer)
      end

      it 'should add User ID to gon' do
        expect(subject['User ID']).to eq(user.id)
      end
    end

    context 'without a signed in user' do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        controller.send(:add_user_id_to_gtm_data_layer)
      end

      it 'should not add User ID to gon' do
        expect(subject['User ID']).to be_nil
      end
    end
  end
end
