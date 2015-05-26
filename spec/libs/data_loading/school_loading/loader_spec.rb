require 'spec_helper'
require 'libs/data_loading/shared_examples_for_loaders'

describe SchoolLoading::Loader do

  # it_behaves_like 'a loader', SchoolLoading::Loader

  describe '#school_insert' do
    let(:subject) { SchoolLoading::Loader.new(nil, nil, 'osp_form') }


    after do
      clean_models :fl, EspResponse
      clean_models OspFormResponse
      clean_models UpdateQueue
      clean_models School
      clean_models User, UserProfile
    end

    # context 'when inserting newer data than the db has' do
    #   let(:value_row) { [FactoryGirl.build(:alameda_high_school, modified: Time.now-10000000,id:2)] }
    #
    #   let(:update) {
    #     {
    #         entity_state: "ca",
    #         entity_id: 2,
    #         entity_type:"school",
    #         value: "http://www.google.com",
    #         member_id: 27620,
    #         created: Time.now,
    #         source: "manually entered by school official"
    #     }
    #   }
    #   let(:school_update) { SchoolLoading::Update.new('home_page_url', update) }
    #
    #
    #   it 'should have the correct source' do
    #           subject.load!
    #           School.on_db(:ca).all.each do |response|
    #             expect(response.home_page_url).to eq(esp_update.value)
    #           end
    #         end
    # end
    # context 'when inserting older data than the db has' do
    #   let(:value_row) { [FactoryGirl.build(:esp_response, created: Time.now+10000000)] }
    #   let(:update) {
    #     {
    #         entity_state: "fl",
    #         entity_id: 871,
    #         value: "after",
    #         member_id: 27620,
    #         created: Time.now,
    #         esp_source: "osp"
    #     }
    #   }
    #   let(:esp_update) { EspResponseLoading::Update.new('before_after_care', update, 'osp_form') }
    #
    #
    #   it 'should create a disabled row in esp' do
    #     expect(subject).to_not receive(:disable!)
    #     expect(subject).to receive(:insert_into!).with(esp_update, active: false)
    #     subject.handle_update(esp_update, value_row)
    #   end
    # end

    # context 'when inserting and db has no data' do
    #   let(:value_row) { [] }
    #   let(:update) {
    #     {
    #         entity_state: "fl",
    #         entity_id: 871,
    #         value: "after",
    #         member_id: 27620,
    #         created: Time.now,
    #         esp_source: "osp"
    #     }
    #   }
    #   let(:esp_update) { EspResponseLoading::Update.new('before_after_care', update, 'osp_form') }
    #
    #
    #   it 'should create a row in esp' do
    #     expect(subject).to_not receive(:disable!)
    #     expect(subject).to receive(:insert_into!).with(esp_update, active: true)
    #     subject.handle_update(esp_update, value_row)
    #   end
    # end

  end


  # describe '#insert_into!' do
  #   let(:subject) { EspResponseLoading::Loader.new(nil, nil, 'osp_form') }
  #   after do
  #     clean_models :ca, EspResponse
  #     clean_models OspFormResponse
  #     clean_models UpdateQueue
  #     clean_models User, UserProfile
  #   end
  #   context "inserting data in db" do
  #     let(:update) {
  #       {
  #           entity_state: "ca",
  #           entity_id: 871,
  #           value: "after",
  #           member_id: 27620,
  #           created: '2015-03-30T14:04:22-07:00',
  #           esp_source: "osp"
  #       }
  #     }
  #     let(:esp_update) { EspResponseLoading::Update.new('before_after_care', update, 'osp_form') }
  #     it 'should have the correct source' do
  #       subject.insert_into!(esp_update, active: true)
  #       EspResponse.on_db(:ca).all.each do |response|
  #         expect(response.response_value).to eq(esp_update.value)
  #       end
  #     end
  #
  #     it 'should have the correct created time' do
  #       subject.insert_into!(esp_update, active: true)
  #       EspResponse.on_db(:ca).all.each do |response|
  #         expect(response.created).to eq(esp_update.created)
  #       end
  #     end
  #
  #     it 'should have the correct member id' do
  #       subject.insert_into!(esp_update, active: true)
  #       EspResponse.on_db(:ca).all.each do |response|
  #         expect(response.member_id).to eq(esp_update.member_id)
  #       end
  #     end
  #
  #
  #     it 'should have the correct value' do
  #       subject.insert_into!(esp_update, active: true)
  #       EspResponse.on_db(:ca).all.each do |response|
  #         expect(response.response_value).to eq(esp_update.value)
  #       end
  #     end
  #
  #     it 'should have the correct response key' do
  #       subject.insert_into!(esp_update, active: true)
  #       EspResponse.on_db(:ca).all.each do |response|
  #         expect(response.response_key).to eq(esp_update.data_type)
  #       end
  #     end
  #
  #     it 'should have the true active flag' do
  #       subject.insert_into!(esp_update, active: true)
  #       EspResponse.on_db(:ca).all.each do |response|
  #         expect(response.active).to eq(true)
  #       end
  #     end
  #     it 'should have the false active flag' do
  #       subject.insert_into!(esp_update, active: false)
  #       EspResponse.on_db(:ca).all.each do |response|
  #         expect(response.active).to eq(false)
  #       end
  #     end
  #   end
  # end
end