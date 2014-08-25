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

  context 'by location search' do

    before do
      set_up_by_location_search
    end

    it 'should display rating, distance and fit sorting, in that order' do
      expect(page).to have_content 'Sort by: Rating Distance Fit'
    end
  end

  context 'by name search' do

    before do
      set_up_by_name_search
    end

    it 'should display rating, distance and fit sorting, in that order' do
      expect(page).to have_content 'Sort by: Relevance Rating Fit'
    end
  end

  context 'no results' do

    before do
      set_up_by_name_search('xkcd')
    end

    it 'should not display sort options' do
      expect(page).to_not have_content 'Sort by:'
    end
  end
end

