require 'spec_helper'
require_relative '../../features/search/search_spec_helper'
require 'controllers/concerns/advertising_helper_shared'

describe 'search/_search_results.html.erb', js: true do
  include SearchSpecHelper

  context 'with ads turned on', js: false do
    # Be careful, these tests fail if JS is on because they look for hidden divs!
    [0, 4, 5, 10, 20, 25].each do |num_results|
      context "and with #{num_results} results" do
        before do
          set_up_city_browse('oh','youngstown', "limit=#{num_results}")
          @divs = ads_and_search_results_divs
        end
        after { clean_dbs :us_geo; }
        it 'should show the correct ads' do
          expect(@divs).to eq(expected_slots_list(num_results))
        end
      end
    end
  end

  context 'with ads turned off' do

    [0, 4, 5, 10, 20, 25].each do |num_results|
      context "and with #{num_results} results" do

        before do
          create_city_mapping = Proc.new { create(:hub_city_mapping, city: 'indianapolis', state: 'IN') }
          set_up_city_browse('in','indianapolis', "limit=#{num_results}") { create_city_mapping.call }
        end
        after(:each) { clean_dbs :gs_schooldb }

        it 'should show the correct ads' do
          expect(page.find(:css, '.js-responsiveSearchPage')).to_not have_selector('.gs_ad_slot')
        end
      end
    end
  end

  describe 'ad targeting', js: true do

    context 'city browse' do

      before do
        set_up_city_browse('mi','Grand Rapids')
      end

      ad_targeting_hash = {
        'env' => ENV_GLOBAL['advertising_env'],
        'template' => 'search',
        'City' => 'GrandRapid',
        'State' => 'MI'
      }

      it_should_behave_like 'a controller that sets the gon.set_ad_targeting hash', ad_targeting_hash

      it 'should target the state and city' do
        ad_targeting = page.evaluate_script('gon.ad_set_targeting')
        expect(ad_targeting['City']).to eq('GrandRapid') # Remove spaces and truncate at 10 characters
        expect(ad_targeting['State']).to eq('MI')
      end
    end

    context 'district browse' do

      before do
        set_up_district_browse('de','Appoquinimink School District','Appoquinimink')
      end

      it 'should target the state and city' do
        ad_targeting = page.evaluate_script('gon.ad_set_targeting')
        expect(ad_targeting['City']).to eq('Appoquinim') # Remove spaces and truncate at 10 characters
        expect(ad_targeting['State']).to eq('DE')
      end
    end

    context 'by name' do

      before do
        set_up_by_name_search('dover elementary', 'DE')
      end

      it 'should target the state' do
        ad_targeting = page.evaluate_script('gon.ad_set_targeting')
        expect(ad_targeting['City']).to be_nil
        expect(ad_targeting['State']).to eq('DE')
      end
    end

    context 'by location' do

      before do
        set_up_by_location_search('100 North Dupont Road', 'Wilmington', 19807, 'DE', 39.752831, -75.588326)
      end

      it 'should target the state and city' do
        ad_targeting = page.evaluate_script('gon.ad_set_targeting')
        expect(ad_targeting['City']).to eq('Wilmington') # Remove spaces and truncate at 10 characters
        expect(ad_targeting['State']).to eq('DE')
      end
    end
  end
end
