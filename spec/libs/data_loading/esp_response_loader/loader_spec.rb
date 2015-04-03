require 'spec_helper'
require 'libs/data_loading/shared_examples_for_loaders'

describe EspResponseLoading::Loader do

  it_behaves_like 'a loader', EspResponseLoading::Loader

  describe '#esp_insert' do
    let(:subject) { EspResponseLoading::Loader.new(nil, nil, 'osp_form') }


    after do
      clean_models :fl, EspResponse
      clean_models OspFormResponse
      clean_models UpdateQueue
      clean_models User, UserProfile
    end

    context 'when inserting newer data than the db has' do
      let(:value_row) { [FactoryGirl.build(:esp_response, created: Time.now-10000000)] }
      let(:update) {
        {
            entity_state: "fl",
            entity_id: 871,
            value: "after",
            member_id: 27620,
            created: Time.now,
            esp_source: "osp"
        }
      }
      let(:esp_update) { EspResponseLoading::Update.new('before_after_care', update, 'osp_form') }


      it 'should create a row in esp and disable the existing rows' do
        expect(subject).to receive(:disable!).with(esp_update, value_row)
        expect(subject).to receive(:insert_into!).with(esp_update, active: true)
        subject.handle_update(esp_update, value_row)
      end
    end
    context 'when inserting older data than the db has' do
      let(:value_row) { [FactoryGirl.build(:esp_response, created: Time.now+10000000)] }
      let(:update) {
        {
            entity_state: "fl",
            entity_id: 871,
            value: "after",
            member_id: 27620,
            created: Time.now,
            esp_source: "osp"
        }
      }
      let(:esp_update) { EspResponseLoading::Update.new('before_after_care', update, 'osp_form') }


      it 'should create a disabled row in esp' do
        expect(subject).to_not receive(:disable!)
        expect(subject).to receive(:insert_into!).with(esp_update, active: false)
        subject.handle_update(esp_update, value_row)
      end
    end

    context 'when inserting and db has no data' do
      let(:value_row) { [] }
      let(:update) {
        {
            entity_state: "fl",
            entity_id: 871,
            value: "after",
            member_id: 27620,
            created: Time.now,
            esp_source: "osp"
        }
      }
      let(:esp_update) { EspResponseLoading::Update.new('before_after_care', update, 'osp_form') }


      it 'should create a row in esp' do
        expect(subject).to_not receive(:disable!)
        expect(subject).to receive(:insert_into!).with(esp_update, active: true)
        subject.handle_update(esp_update, value_row)
      end
    end

  end

  describe '#disable!' do
    let(:subject) { EspResponseLoading::Loader.new(nil, nil, 'osp_form') }


    after do
      clean_models :ca, EspResponse
      clean_models OspFormResponse
      clean_models UpdateQueue
      clean_models User, UserProfile
    end

    context 'when disabling data in db' do
      before do
        FactoryGirl.create(:esp_response, response_key: 'before_after_care', response_value: 'before', school_id: update[:entity_id])
        FactoryGirl.create(:esp_response, response_key: 'before_after_care', response_value: 'after', school_id: update[:entity_id])
      end

      let(:update) {
        {
            entity_state: "ca",
            entity_id: 871,
            value: "after",
            member_id: 27620,
            created: Time.now,
            esp_source: "osp"
        }
      }
      let(:esp_update) { EspResponseLoading::Update.new('before_after_care', update, 'osp_form') }


      it 'should update the data in esp with inactive status regardless of response_value' do
        subject.disable!(esp_update, EspResponse.on_db(:ca).where(response_key: 'before_after_care', school_id: update[:entity_id]))

        EspResponse.on_db(:ca).all.each do |response|
          expect(response.active).to eq(false)
        end
      end
    end


  end

  describe '#insert_into!' do
    let(:subject) { EspResponseLoading::Loader.new(nil, nil, 'osp_form') }
    after do
      clean_models :ca, EspResponse
      clean_models OspFormResponse
      clean_models UpdateQueue
      clean_models User, UserProfile
    end
    context "inserting data in db" do
      let(:update) {
        {
            entity_state: "ca",
            entity_id: 871,
            value: "after",
            member_id: 27620,
            created: '2015-03-30T14:04:22-07:00',
            esp_source: "osp"
        }
      }
      let(:esp_update) { EspResponseLoading::Update.new('before_after_care', update, 'osp_form') }
      it 'should have the correct source' do
        subject.insert_into!(esp_update, active: true)
        EspResponse.on_db(:ca).all.each do |response|
          expect(response.response_value).to eq(esp_update.value)
        end
      end

      it 'should have the correct created time' do
        subject.insert_into!(esp_update, active: true)
        EspResponse.on_db(:ca).all.each do |response|
          expect(response.created).to eq(esp_update.created)
        end
      end

      it 'should have the correct member id' do
        subject.insert_into!(esp_update, active: true)
        EspResponse.on_db(:ca).all.each do |response|
          expect(response.member_id).to eq(esp_update.member_id)
        end
      end


      it 'should have the correct value' do
        subject.insert_into!(esp_update, active: true)
        EspResponse.on_db(:ca).all.each do |response|
          expect(response.response_value).to eq(esp_update.value)
        end
      end

      it 'should have the correct response key' do
        subject.insert_into!(esp_update, active: true)
        EspResponse.on_db(:ca).all.each do |response|
          expect(response.response_key).to eq(esp_update.data_type)
        end
      end

      it 'should have the true active flag' do
        subject.insert_into!(esp_update, active: true)
        EspResponse.on_db(:ca).all.each do |response|
          expect(response.active).to eq(true)
        end
      end
      it 'should have the false active flag' do
        subject.insert_into!(esp_update, active: false)
        EspResponse.on_db(:ca).all.each do |response|
          expect(response.active).to eq(false)
        end
      end
    end
  end
end