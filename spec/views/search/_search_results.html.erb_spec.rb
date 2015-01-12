require 'spec_helper'
require_relative '../../features/search/search_spec_helper'

describe 'search/_search_results.html.erb', js: true do
  include SearchSpecHelper

  let(:header_ad_slots) {{
      desktop: [
          {name:'Responsive_Search_Content_Top_728x90'}
      ],
      mobile: [
          {name:'Responsive_Mobile_Search_Content_Top_320x50'},
      ]
  }}


  let(:footer_ad_slots) {{
      desktop: [
          {name:'Responsive_Search_Footer_728x90'}
      ],
      mobile: [
          {name:'Responsive_Mobile_Search_Footer_320x50'}
      ]
  }}

  let(:results_ad_slots) {{
      desktop: [
          {name:'Responsive_Search_After4_728x90'},
          {name:'Responsive_Search_After8_Text_728x60'},
          [
              {name:'Responsive_Search_After12_Left_300x250'},
              {name:'Responsive_Search_After12_Right_300x250'}
          ],
          {name:'Responsive_Search_After16_728x90'},
          {name:'Responsive_Search_After20_728x90'}
      ],
      mobile: [
          {name:'Responsive_Mobile_Search_After4_300x250'},
          {name:'Responsive_Mobile_Search_After8_Text_320x60'},
          {name:'Responsive_Mobile_Search_After12_320x50'},
          {name:'Responsive_Mobile_Search_After16_300x250'},
          {name:'Responsive_Mobile_Search_After20_320x50'}
      ]
  }}

  context 'with ads turned on' do

    [0, 4, 5, 10, 20, 25].each do |num_results|
      context "and with #{num_results} results" do

        before do
          set_up_city_browse('oh','youngstown', "limit=#{num_results}")
        end

        it 'should show the correct ads' do
          slots = create_slots_list(num_results)
          slots.each_with_index do |slot, index|
            next unless slot[:name]
            desktop_or_mobile = slot[:name].include?('Mobile') ? 'Mobile_' : ''
            expect(ads_and_search_results_divs[index]['data-dfp']).to eq(slot[:name])
          end
        end
      end
    end
  end

  context 'with ads turned off' do

    [0, 4, 5, 10, 20, 25].each do |num_results|
      context "and with #{num_results} results" do

        before do
          set_up_city_browse('in','indianapolis', "limit=#{num_results}") { FactoryGirl.create(:hub_city_mapping, city: 'indianapolis', state: 'IN') }
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

      it 'should target the state and city' do
        ad_targeting = page.evaluate_script('gon.ad_set_targeting')
        expect(ad_targeting['City']).to eq('GrandRapid') # Remove spaces and truncate at 10 characters
        expect(ad_targeting['State']).to eq('mi')
      end
    end

    context 'district browse' do

      before do
        set_up_district_browse('de','Appoquinimink School District','Appoquinimink')
      end

      it 'should target the state and city' do
        ad_targeting = page.evaluate_script('gon.ad_set_targeting')
        expect(ad_targeting['City']).to eq('Appoquinim') # Remove spaces and truncate at 10 characters
        expect(ad_targeting['State']).to eq('de')
      end
    end

    context 'by name' do

      before do
        set_up_by_name_search('dover elementary', 'DE')
      end

      it 'should target the state' do
        ad_targeting = page.evaluate_script('gon.ad_set_targeting')
        expect(ad_targeting['City']).to be_nil
        expect(ad_targeting['State']).to eq('de')
      end
    end

    context 'by location' do

      before do
        set_up_by_location_search('100 North Dupont Road', 'Wilmington', 19807, 'DE', 39.752831, -75.588326)
      end

      it 'should target the state and city' do
        ad_targeting = page.evaluate_script('gon.ad_set_targeting')
        expect(ad_targeting['City']).to eq('Wilmington') # Remove spaces and truncate at 10 characters
        expect(ad_targeting['State']).to eq('de')
      end
    end
  end
end
