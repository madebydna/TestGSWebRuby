require 'spec_helper'
require 'models/osp/osp_shared_contexts'

shared_example 'should return an array' do
  expect(subject.values_for(response_key, question_id)).to be_instance_of Array
end

describe OspData do
  let(:esp_membership_id) { 1 }
  let(:school) { FactoryGirl.build(:school, id: 1, state: 'CA')}
  subject { OspData.for(school) }
  describe '#values_for' do
    with_shared_context 'for a particular response_key and question_id', *[:boys_sports, 1] do
      with_shared_context 'when there is an osp_form_response and no school_cache data' do
        include_example 'should return an array'
        with_shared_context 'values from osp_form_responses and school_cache for comparison' do
          it 'should return values from osp_form_responses table' do
            values = subject.values_for(response_key, question_id)
            expect(school_cache_values).to be_empty
            expect(osp_form_response_values).to include values
          end
        end
      end

      with_shared_context 'when there is a school_cache and no osp_form_response' do
        include_example 'should return an array'
        with_shared_context 'values from osp_form_responses and school_cache for comparison' do
          it 'should return the school_cache data' do
            values = subject.values_for(response_key, question_id)
            expect(osp_form_response_values).to be_empty
            expect(values).to eql school_cache_values
          end
        end
      end

      with_shared_context 'when there are multiple osp_form_responses and no school_cache data' do
        include_example 'should return an array'
        with_shared_context 'values from osp_form_responses and school_cache for comparison' do
          it 'should return the most recent osp_form_response values' do
            values = subject.values_for(response_key, question_id)
            expect(school_cache_values).to be_empty
            expect(osp_form_response_values.count).to eql 2 #asserts multiple value sets
            expect(osp_form_response_values).to include values
          end
        end
      end

      with_shared_context 'when school_cache data is newer than osp_form_response data' do
        include_example 'should return an array'
        with_shared_context 'values from osp_form_responses and school_cache for comparison' do
          it 'should return school_cache data' do
            values = subject.values_for(response_key, question_id)
            expect(osp_form_response_values).to_not include values
            expect(values).to eql school_cache_values
          end
        end
      end

      with_shared_context 'when osp_form_response data is newer than school_cache data' do
        include_example 'should return an array'
        with_shared_context 'values from osp_form_responses and school_cache for comparison' do
          it 'should return osp_form_response data' do
            values = subject.values_for(response_key, question_id)
            expect(school_cache_values).to_not eql values
            expect(osp_form_response_values).to include values
          end
        end
      end
    end
  end
end
