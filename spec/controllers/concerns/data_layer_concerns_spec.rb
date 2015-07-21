require 'spec_helper'

describe DataLayerConcerns do
  let(:controller) { FakeController.new }

  before(:each) do
    controller.request = request
    controller.gon.data_layer_hash = {}
  end
  after(:each) do
    clean_models User
    clean_models HubCityMapping
    clean_models EspMembership
  end
  before(:all) do
    class FakeController < ActionController::Base
      include DataLayerConcerns
    end
  end
  after(:all) do
    Object.send :remove_const, :FakeController
  end

  describe '#add_user_info_to_gtm_data_layer' do
    subject { controller.gon.data_layer_hash }

    context 'with a signed in regular user' do
      let(:user) {FactoryGirl.create(:user)}
      before do
        allow(controller).to receive(:current_user).and_return(user)
        controller.send(:add_user_info_to_gtm_data_layer)
      end

      it 'should add User ID to gon' do
        expect(subject['User ID']).to eq(user.id)
      end

      it 'should add User Type regular to gon' do
        expect(subject['GS User Type']).to eq('regular')
      end
    end

    context 'with a signed in osp user' do
      let(:osp_user) {FactoryGirl.create(:user, :with_approved_esp_membership)}

      before do
        allow(controller).to receive(:current_user).and_return(osp_user)
        controller.send(:add_user_info_to_gtm_data_layer)
      end

      it 'should add User ID to gon' do
        expect(subject['User ID']).to eq(osp_user.id)
      end

      it 'should add User Type OSP to gon' do
        expect(subject['GS User Type']).to eq('OSP')
      end
    end

    context 'without a signed in user' do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        controller.send(:add_user_info_to_gtm_data_layer)
      end

      it 'should not add User ID to gon' do
        expect(subject['User ID']).to be_nil
      end
    end
  end

  describe '#add_collection_id_to_gtm_data_layer' do
    let(:hub) { HubCityMapping.create(collection_id: 1, state: 'KM') }
    subject { controller.gon.data_layer_hash }

    context 'with a hub set' do
      before do
        controller.instance_variable_set(:@hub, hub)
        controller.send(:add_collection_id_to_gtm_data_layer)
      end

      it 'should add Collection ID to gon' do
        expect(subject['Collection ID']).to eq(hub.collection_id)
      end
    end

    context 'without a hub set' do
      before do
        controller.instance_variable_set(:@hub, nil)
        controller.send(:add_collection_id_to_gtm_data_layer)
      end

      it 'should not add Collection ID to gon' do
        expect(subject['Collection ID']).to be_nil
      end
    end
  end

  describe '#trigger_event' do
    it 'logs a single event into the cookie' do
      allow(controller).to receive(:read_cookie_value).and_return(nil)
      e = [{category: 'cat', action: 'action', label: 'label', value: 'value', non_interactive: true}]
      expect(controller).to receive(:write_cookie_value).with(:GATracking, e, 'events')
      controller.send(:trigger_event, 'cat', 'action', 'label', 'value', true)
    end

    it 'adds an event into an existing cookie' do
      allow(controller).to receive(:read_cookie_value).and_return([{category: 'cat1', action: 'action1', label: 'label1'}])
      e = [{category: 'cat1', action: 'action1', label: 'label1'},{category: 'cat2', action: 'action2', label: nil, value: nil, non_interactive: false}]
      expect(controller).to receive(:write_cookie_value).with(:GATracking, e, 'events')
      controller.send(:trigger_event, 'cat2', 'action2')
    end
  end
end
