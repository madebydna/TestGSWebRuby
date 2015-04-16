require 'spec_helper'

shared_context 'user esp_membership status is' do | user_type |
  factory_girl_mapping = {
    approved: :with_approved_esp_membership,
    provisional: :with_provisional_esp_membership
  }

  let(:current_user) { FactoryGirl.create(:user, factory_girl_mapping[user_type]) }

  after { clean_models User, UserProfile, EspMembership }
end

shared_context 'using a basic set of question keys and answers' do
  let(:question_keys_and_answers) do
    {
      before_after_care: [:before, :after],
      transportation: [:bus, :train, :canoe],
      sports: [:basket_weaving, :plate_spinning]
    }
  end
end

shared_context 'Osp question key and answers saved in the db' do
  before do
    question_keys_and_answers.each_key do |key|
      FactoryGirl.create(:osp_question, esp_response_key: key)
    end
  end
  after { clean_models OspQuestion }
end

#needs to execute after current user is set
shared_context 'setup osp controller instance var dependencies' do
  let(:esp_membership) { current_user.esp_memberships.first }
  let(:state) { esp_membership.state }
  let(:school_id) { esp_membership.school_id }
  let(:school) { FactoryGirl.build(:alameda_high_school, id: school_id, state: state) }

  before do
    controller.instance_variable_set(:@current_user, current_user)
    allow(School).to receive(:find_by_state_and_id).and_return(school)
  end

  after { clean_models EspMembership }
end

#depends on having all dependencies met
shared_context 'send osp form submit request' do
  before do
    get :submit, { state: school.state, schoolId: school.id }.merge(question_keys_and_answers)
  end
  after { clean_models UpdateQueue, OspFormResponse }
end

shared_context 'and saving the data will return an error' do
  before do
    allow(controller).to receive(:create_osp_form_response!).and_return('This is an error')
  end
end
