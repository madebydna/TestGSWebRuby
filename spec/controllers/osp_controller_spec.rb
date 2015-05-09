require 'spec_helper'
require 'controllers/contexts/osp_shared_contexts'

describe Admin::OspController do

  describe '#show' do
    with_shared_context 'user esp_membership status is', :approved do
      let(:school) { FactoryGirl.build(:alameda_high_school, id: 1) }
      before do
        controller.instance_variable_set(:@current_user, current_user)
        allow(School).to receive(:find_by_state_and_id).and_return school
      end
      after { clean_models School }
  
      it 'should redirect user to account page if user does not have access to osp' do
        get :show, state: school.state, schoolId: school.id
        expect(response).to redirect_to(my_account_url)
      end
      {
          osp_basic_information: 1, #page number
          osp_academics: 2,
          osp_extracurricular_culture: 3,
          osp_facilities_staff: 4
      }.each do |page, page_number|
        it "should render #{page} page if user has access to osp and page is #{page_number}" do
          get :show, state: school.state, schoolId: school.id, page: page_number
          expect(response).to render_template(page)
        end

        it 'should have correct osp page meta tag' do
          allow(controller).to receive(:set_meta_tags)
        end

        it 'should have correct omniture tracking' do
          allow(controller).to receive(:set_omniture_data_for_school)
          allow(controller).to receive(:set_omniture_data_for_user_request)
        end
      end
    end

    with_shared_context 'user esp_membership status is', :provisional do
      let(:school) { FactoryGirl.build(:alameda_high_school, id: 1) }
      before do
        controller.instance_variable_set(:@current_user, current_user)
        allow(School).to receive(:find_by_state_and_id).and_return school
      end
      after { clean_models School }
 
      it 'should have called flash_notice' do
        expect(controller).to receive(:flash_notice)
        get :show, state: school.state, schoolId: school.id
      end
    end
  end

  describe '#submit' do
    describe 'redirecting' do
      include_context 'user esp_membership status is', :approved
      include_context 'setup osp controller instance var dependencies'
      before { allow(current_user).to receive(:provisional_or_approved_osp_user?).and_return true }
      {
        osp_basic_information: 1, #page number
        osp_academics: 2,
        osp_extracurricular_culture: 3,
        osp_facilities_staff: 4
      }.each do |page, page_number|
        it "should redirect user back to #{page} page when submit is clicked on the #{page} page" do
          post :submit, state: school.state, schoolId: school.id, page: page_number
          expect(response.location).to match(admin_osp_page_url.chop) #chop trailing slash
        end
      end
    end

    context 'when user is an approved osp user and there are no errors' do
      include_context 'user esp_membership status is', :approved
      include_context 'using a basic set of question keys and answers'
      include_context 'Osp question key and answers saved in the db'
      include_context 'setup osp controller instance var dependencies'
      with_shared_context 'send osp form submit request' do
        it 'should insert rows into update_queue and osp_form_responses tables' do
          expect(UpdateQueue.count).to_not be 0
          expect(OspFormResponse.count).to_not be 0
        end
  
        it 'should insert the same blobs into update_queue and form_response tables' do
          update_queue_blobs = UpdateQueue.all.map(&:update_blob)
          osp_form_response_blobs = OspFormResponse.all.map(&:response)
          expect(update_queue_blobs.count).to eql(osp_form_response_blobs.count)
  
          update_queue_blobs.each do |update_queue_blob|
            expect(osp_form_response_blobs).to include(update_queue_blob)
          end
        end
        it 'should use the query parameter question keys as keys in the response blobs' do
          osp_form_response_keys = OspFormResponse.all.map { |item| JSON.parse(item.response).keys.first }
          question_keys_and_answers.each_key do |key|
            expect(osp_form_response_keys).to include(key.to_s)
          end
        end
        it 'should insert a blob that uses the current user and state/school_id from the request' do
          osp_form_response_values = OspFormResponse.all.map { |item| JSON.parse(item.response).values.first }.flatten
          osp_form_response_values.each do |value_hash|
            expect(value_hash['entity_state']).to eql(state)
            expect(value_hash['member_id']).to eql(esp_membership.id)
            expect(value_hash['entity_id']).to eql(school_id)
          end
        end
        it 'should insert a osp_form_response row that uses the current users esp_membership_id' do
          membership_ids = OspFormResponse.all.map(&:esp_membership_id)
          membership_ids.each do |id|
            expect(id).to eql(esp_membership.id)
          end
        end

        it 'should escape html, iframe and script tags' do
          # escaped method is called
          # escaped method is acoutally escaping
        end
      end

      context 'send osp form submit request' do
        after { clean_models UpdateQueue, OspFormResponse }

        it 'should have called flash_success' do
          expect(controller).to receive(:flash_success)
          post :submit, { state: school.state, schoolId: school.id }.merge(request_keys_and_answers)
        end
      end
    end
  end

  context 'when user is an approved osp user and there are errors' do
    include_context 'user esp_membership status is', :approved
    include_context 'using a basic set of question keys and answers'
    include_context 'Osp question key and answers saved in the db'
    include_context 'and saving the data will return an error'
    include_context 'setup osp controller instance var dependencies'
    context 'send osp form submit request' do
      after { clean_models UpdateQueue, OspFormResponse }
      it 'should have called flash_error' do
        expect(controller).to receive(:flash_error)
        post :submit, { state: school.state, schoolId: school.id }.merge(request_keys_and_answers)
      end
    end
  end


  context 'when user is a provisional osp user and there are errors' do
    include_context 'user esp_membership status is', :provisional
    include_context 'using a basic set of question keys and answers'
    include_context 'Osp question key and answers saved in the db'
    include_context 'and saving the data will return an error'
    include_context 'setup osp controller instance var dependencies'
    context 'send osp form submit request' do
      after { clean_models UpdateQueue, OspFormResponse }
      it 'should have called flash_notice' do
        expect(controller).to receive(:flash_error)
        post :submit, { state: school.state, schoolId: school.id }.merge(request_keys_and_answers)
      end
      it 'should have called flash_error' do
        expect(controller).to receive(:flash_error)
        post :submit, { state: school.state, schoolId: school.id }.merge(request_keys_and_answers)
      end
    end
  end

  describe '#approve_provisional_osp_user_data' do
    let(:esp_membership_id) { 1 }
    before do
      3.times { FactoryGirl.create(:osp_form_response, esp_membership_id: esp_membership_id) }
      allow(controller).to receive(:params).and_return({membership_id: esp_membership_id})
      allow(controller).to receive(:render)
    end
    after do
      clean_models OspFormResponse, UpdateQueue
    end

    it 'should save rows to update_queue' do
      expect(UpdateQueue.count).to eql 0
      controller.approve_provisional_osp_user_data
      expect(UpdateQueue.count).to eql 3
    end

    context 'osp_form_responses and update_queue' do
      it 'should have the same blob' do
        controller.approve_provisional_osp_user_data
        update_queue_blobs = UpdateQueue.all.map(&:update_blob)
        osp_form_responses = OspFormResponse.all
        osp_form_responses.each do |osp_form_response|
          expect(update_queue_blobs).to include(osp_form_response.response)
        end
      end
    end
  end
end
