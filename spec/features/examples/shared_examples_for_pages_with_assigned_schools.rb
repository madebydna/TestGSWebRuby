require 'spec_helper'

shared_examples_for 'a page with assigned schools among search results' do
  describe_mobile_and_desktop do
    context 'when a school is displayed as both an assigned school and a search result' do
      it 'should have the same distance value'
      it 'should have the same review count'
    end
  end
end
