require 'spec_helper'

shared_context 'for a particular response_key and question_id' do |key, id|
  let(:response_key) { key.to_s }
  let(:question_id) { id }
end

shared_context 'when there is an osp_form_response and no school_cache data' do
  before { FactoryGirl.create(:osp_form_response_with_boys_sports, :with_esp_member, osp_question_id: 1, esp_membership_id: esp_membership_id) }
  after { clean_models(OspFormResponse, EspMembership) }
end

shared_context 'when there is a school_cache and no osp_form_response' do
  before { FactoryGirl.create(:school_cache_esp_responses, school_id: school.id) }
  after { clean_models(SchoolCache) }
end

shared_context 'when there are multiple osp_form_responses and no school_cache data' do
  before { FactoryGirl.create(:osp_form_response_with_boys_sports, :with_esp_member, osp_question_id: 1, esp_membership_id: esp_membership_id) }
  before { FactoryGirl.create(:osp_form_response_with_different_boys_sports, updated: (Time.now - 1.day), osp_question_id: 1, esp_membership_id: esp_membership_id) }
  after { clean_models(OspFormResponse, EspMembership) }
end

shared_context 'when school_cache data is newer than osp_form_response data' do
  before { FactoryGirl.create(:osp_form_response_that_is_a_day_old, :with_esp_member, osp_question_id: 1, esp_membership_id: esp_membership_id) }
  before { FactoryGirl.create(:school_cache_esp_responses, school_id: school.id) }
  after { clean_models(OspFormResponse, EspMembership, SchoolCache) }
end

shared_context 'when osp_form_response data is newer than school_cache data' do
  before { FactoryGirl.create(:osp_form_response_that_is_a_day_in_the_future, :with_esp_member, osp_question_id: 1, esp_membership_id: esp_membership_id) }
  before { FactoryGirl.create(:school_cache_esp_responses, school_id: school.id) }
  after { clean_models(OspFormResponse, EspMembership, SchoolCache) }
end

shared_context 'values from osp_form_responses and school_cache for comparison' do
  let(:osp_form_response_values) do
    osp_form_responses = OspFormResponse
    .joins(:esp_membership)
    .where('esp_membership.state' => school.state ,'esp_membership.school_id'=> school.id, osp_question_id: question_id)
    .order('osp_question_id')
    .order('updated desc ')

    #get sets of values from osp_form_responses. Will return something like ['before', 'after'] or [['soccer', 'basketball'],['tennis', 'badminton']]
    osp_form_responses.map do |form_response|
      JSON.parse(form_response.response).values[0].map {|v|v['value']}
    end
  end

  let(:school_cache_values) do
    school_cache = SchoolCache.where(school_id: school.id, name: 'esp_responses', state: school.state).first

    return [] unless school_cache.present?

    #get values from school_cache. Will return something like ['soccer', 'basketball']
    JSON.parse(school_cache.value)[response_key].try(:keys) || []
  end
end

