require 'spec_helper'

shared_context 'with state=ca and school_id=1' do
  let(:state) { 'ca' }
  let(:school_id) { 1 }
end

shared_context 'user esp_membership status is' do | user_type |
  include_context 'with state=ca and school_id=1'
  let(:factory_girl_mapping) {
    {
      approved: :with_approved_esp_membership,
      provisional: :with_provisional_esp_membership,
      super: :with_approved_superuser_membership
    }
  }
  let(:factory_girl_options) {
    {
      approved: {state: state, school_id: school_id},
      provisional: {state: state, school_id: school_id},
      super: {state: nil, school_id: nil}
    }
  }

  let(:current_user) { FactoryGirl.create(:user, factory_girl_mapping[user_type], factory_girl_options[user_type]) }

  after { clean_models :gs_schooldb, User, UserProfile, EspMembership, Role, MemberRole }
end

shared_context 'set question and request keys' do
  let(:question_keys_and_answers) do
    questions_with_ids_and_answers.inject({}) do |h, question|
      h.merge({question[:response_key] => question[:answers]})
    end
  end
  let(:request_keys_and_answers) do
    questions_with_ids_and_answers.inject({}) do |h, question|
      h.merge({"#{question[:id]}-#{question[:response_key]}" => question[:answers]})
    end
  end
end

shared_context 'using a basic set of question keys and answers' do
  let(:questions_with_ids_and_answers) do
    [
      {id: 1, response_key: 'before_after_care', answers: [:before, :after]},
      {id: 2, response_key: 'transportation', answers: [:bus, :train, :canoe]},
      {id: 3, response_key: 'boys_sports', answers: [:basket_weaving, :plate_spinning]}
    ]
  end
  include_context 'set question and request keys'
end

shared_context 'using a set of question keys and valid answers that have validations' do
  let(:questions_with_ids_and_answers) do
    [
      {id: 1, response_key: 'school_phone', answers: ['1234567890']},
      {id: 2, response_key: 'school_fax', answers: ['1234567890']}
    ]
  end
  include_context 'set question and request keys'
end

shared_context 'using a set of question keys and invalid answers that have validations' do
  let(:questions_with_ids_and_answers) do
    [
      {id: 1, response_key: 'school_phone', answers: ['123']},
      {id: 2, response_key: 'school_fax', answers: ['123']}
    ]
  end
  include_context 'set question and request keys'
end

shared_context 'Osp question key and answers saved in the db' do
  before do
    questions_with_ids_and_answers.each do |question|
      FactoryGirl.create(:osp_question, id: question[:id], esp_response_key: question[:response_key])
    end
  end
  after { clean_models :gs_schooldb, OspQuestion }
end

shared_context 'all responses in key value form from the db' do
  #ex { before_care: ['after', 'before'], transportation: ['public'] }
  let(:form_response_values) do
    OspFormResponse.all.inject({}) do |hash, item|
      key_values = JSON.parse(item.response)
      key_values.each do |key, values|
        values.map! { |v| v['value'] }
      end
      hash.merge(key_values)
    end
  end
end

#needs to execute after current user is set
shared_context 'setup osp controller instance var dependencies' do
  let(:esp_membership) { current_user.esp_memberships.first }
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
    get :submit, { state: school.state, schoolId: school.id }.merge(request_keys_and_answers)
  end
  after { clean_models UpdateQueue, OspFormResponse }
end

shared_context 'and saving the data will return an error' do
  before do
    allow(controller).to receive(:create_osp_form_response!).and_return('This is an error')
  end
end
