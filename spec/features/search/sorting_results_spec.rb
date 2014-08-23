require 'spec_helper'
require_relative 'search_spec_helper'

describe 'Sorting search results' do
  include SearchSpecHelper

  context 'city browse' do

    before do
      set_up_city_browse('de','dover')
    end

    it 'should display only rating and fit sorting, in that order' do
      expect(page).to have_content 'Sort by: Rating Fit'
    end
  end

  context 'district browse' do

    before do
      set_up_district_browse('de','Appoquinimink School District')
    end

    it 'should display only rating and fit sorting, in that order' do
      expect(page).to have_content 'Sort by: Rating Fit'
    end
  end
end

