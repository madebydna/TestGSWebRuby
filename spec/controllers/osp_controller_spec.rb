require 'spec_helper'
require 'controllers/contexts/osp_shared_contexts'

describe Admin::OspController do

  describe '#show' do
    let(:current_user) { FactoryGirl.build(:user) }
    let(:school) { FactoryGirl.build(:alameda_high_school) }
    before do
      controller.instance_variable_set(:@current_user, current_user)
      allow(School).to receive(:find_by_state_and_id).and_return school
    end
    after { clean_models School }

    it 'should redirect user to account page if user does not have access to osp' do
      allow(current_user).to receive(:provisional_or_approved_osp_user?).and_return false

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
        allow(current_user).to receive(:provisional_or_approved_osp_user?).and_return true
        get :show, state: school.state, schoolId: school.id, page: page_number
        expect(response).to render_template(page)
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
          get :submit, state: school.state, schoolId: school.id, page: page_number
          expect(response.location).to match(admin_osp_page_url.chop) #chop trailing slash
        end
      end
    end

    context 'when user is an approved osp user and there are no errors' do
      include_context 'user esp_membership status is', :approved
      include_context 'using a basic set of question keys and answers'
      include_context 'Osp question key and answers saved in the db'
      include_context 'setup osp controller instance var dependencies'
      include_context 'send osp form submit request'

      it 'should insert rows into update_queue and osp_form_responses tables' do
        expect(UpdateQueue.count).to_not be 0
        expect(OspFormResponse.count).to_not be 0
      end

      it 'should insert the same blobs into update_queue and form_response tables' do
        update_queue_blobs = UpdateQueue.all.map(&:update_blob)
        osp_form_response_blobs = OspFormResponse.all.map(&:response)
        update_queue_blobs.each_with_index do |update_queue_blob, n|
          expect(update_queue_blob).to eql(osp_form_response_blobs[n])
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
    end
  end

end