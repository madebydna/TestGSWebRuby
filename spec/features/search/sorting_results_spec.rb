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
      expect(page.find('.active-search-sort')).to have_content('Rating')
    end
  end

  context 'district browse' do

    before do
      set_up_district_browse('de','Appoquinimink School District')
    end

    it 'should display only rating and fit sorting, in that order' do
      expect(page).to have_content 'Sort by: Rating Fit'
      expect(page.find('.active-search-sort')).to have_content('Rating')
    end
  end

  context 'by location search' do

    before do
      set_up_by_location_search
    end

    it 'should display rating, distance and fit sorting, in that order' do
      expect(page).to have_content 'Sort by: Rating Distance Fit'
      expect(page.find('.active-search-sort')).to have_content('Distance')
    end
  end

  context 'by name search' do

    before do
      set_up_by_name_search
    end

    it 'should display rating, distance and fit sorting, in that order' do
      expect(page).to have_content 'Sort by: Relevance Rating Fit'
      expect(page.find('.active-search-sort')).to have_content('Relevance')
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

  context 'sorting results by rating' do

    before do
      set_up_city_browse('de','dover','sort=rating_desc')
    end

    it 'should sort by rating descending' do
      prev_rating = 10
      page.all(:css, '.iconx24-icons').each do |rating_div|
        next unless rating_div[:class].include? '-ratings-'
        rating_div[:class].split(' ').each do |cls|
          next unless cls.include? 'ratings'
          rating = cls.split('-')[-1]
          unless rating == 'nr' || prev_rating == 'nr'
            rating = rating.to_i
            expect(rating).to be <= prev_rating
          end
          if prev_rating == 'nr'
            expect(rating).to eq('nr')
          end
          prev_rating = rating
        end
      end
    end
  end

  context 'sorting results by distance' do

    before do
      set_up_by_location_search('100 North Dupont Road', 'Wilmington', 19807, 'DE', 39.752831, -75.588326, 'sort=distance_asc')
    end

    it 'should sort by distance ascending' do
      prev_distance = 0.0
      page.all('span', text: /miles$/).each do |distance_span|
        distance = distance_span.text.split(' ').first.to_f
        expect(distance).to be >= prev_distance
      end
    end
  end
end

