require 'spec_helper'
require_relative 'search_spec_helper'

describe 'Sorting search results', js: true do
  include SearchSpecHelper

  SORT_PREFIX = "Sort by: "

  def active_sort_assertion(sorts, active_sort)
    if sorts.present?
      expect(page.find(sort_dropdown)[:title]).to eq("#{SORT_PREFIX}#{active_sort}")
    end
  end

  let(:sort_option) {'a[data-sort-type]'}
  let(:sort_dropdown) { '[data-id="search-page-sort"]' }

  ['fit', 'no fit'].each do |fit|
    ['rating sort', 'no rating sort'].each do |rating_sort|
      has_fit = fit == 'fit'
      has_rating_sort = rating_sort == 'rating sort'
      query_string = has_fit ? 'transportation%5B%5D=public_transit' : ''
      rating_sort_query_string = has_rating_sort ? 'sort=rating_desc&' : ''
      query_string = rating_sort_query_string + query_string
      context "city browse with #{fit}" do

        sorts = []
        if has_fit
          sorts = ['Rating', 'School name', 'Fit'].map { |s| "#{SORT_PREFIX}#{s}"}
        end
        sorts_text = "#{sorts.join(' ')}"
        default_sort = 'Rating'

        before do
          set_up_city_browse('de','dover', query_string)
          if sorts.present?
            page.find(sort_dropdown).click
          end
        end

        it "should display #{sorts_text}" do
          expect(page.all(sort_option).map{ |b| b.text }.uniq).to eq(sorts)
          active_sort_assertion(sorts, default_sort)
        end
      end

      context "district browse with #{fit} and #{rating_sort}" do

        sorts = []
        if has_fit
          sorts = ['Rating', 'School name', 'Fit'].map { |s| "#{SORT_PREFIX}#{s}"}
        end
        sorts_text = "#{sorts.join(' ')}"

        before do
          set_up_district_browse('de','Appoquinimink School District','Appoquinimink', query_string)
          if sorts.present?
            page.find(sort_dropdown).click
          end
        end

        default_sort = 'Rating'
        active_sort = has_rating_sort ? 'Rating' : default_sort

        it "should display #{sorts_text}" do
          expect(page.all(sort_option).map{ |b| b.text }.uniq).to eq(sorts)
          active_sort_assertion(sorts, active_sort)
        end
      end

      context "by location search with #{fit} and #{rating_sort}" do

        sorts = ['Distance', 'Rating', 'School name']
        if has_fit
          sorts += ['Fit']
        end
        sorts = sorts.map { |s| "#{SORT_PREFIX}#{s}"}
        sorts_text = "#{sorts.join(' ')}"

        before do
          set_up_by_location_search('100 North Dupont Road', 'Wilmington', 19807, 'DE', 39.752831, -75.588326, query_string)
          if sorts.present?
            page.find(sort_dropdown).click
          end
        end

        default_sort = 'Rating'
        active_sort = has_rating_sort ? 'Rating' : default_sort

        it "should display #{sorts_text}" do
          expect(page.all(sort_option).map{ |b| b.text }.uniq).to eq(sorts)
          active_sort_assertion(sorts, active_sort)
        end
      end

      context "by name search with #{fit} and #{rating_sort}" do

        # By name search never has fit
        sorts = ['Relevance', 'Rating', 'School name'].map { |s| "#{SORT_PREFIX}#{s}"}
        sorts_text = "#{sorts.join(' ')}"

        before do
          set_up_by_name_search('dover elementary', 'DE', query_string)
          if sorts.present?
            page.find(sort_dropdown).click
          end
        end

        default_sort = 'Relevance'
        active_sort = has_rating_sort ? 'Rating' : default_sort

        it "should display #{sorts_text}" do
          expect(page.all(sort_option).map{ |b| b.text }.uniq).to eq(sorts)
          active_sort_assertion(sorts, active_sort)
        end
      end
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
      search_results_container = page.find(:css, '.js-searchResultsContainer')
      search_results_container.all(:css, '.iconx24-icons').each do |rating_div|
        next unless rating_div[:class].include? '-ratings-'
        # TODO either make this js-gs-rating-icon test stronger or change how assigned schools inserts the ratings icon
        next if rating_div[:class].include? 'js-gs-rating-icon'
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
      search_results_container = page.find(:css, '.js-searchResultsContainer')
      search_results_container.all('span', text: /miles$/).each do |distance_span|
        distance = distance_span.text.split(' ').first.to_f
        expect(distance).to be >= prev_distance
      end
    end
  end
end

