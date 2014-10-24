require 'spec_helper'
require_relative '../../features/search/search_spec_helper'

describe 'search/_search_results.html.erb' do
  include SearchSpecHelper

  let(:header_ad_slots) {{
      desktop: [
          {name:'Responsive_Search_Results1_728x90',  dimensions: [728, 90]},
      ],
      mobile: [
          {name:'Responsive_Mobile_Search_Results1_320x50',  dimensions: [320, 50]},
      ]
  }}

  let(:footer_ad_slots) {{
      desktop: [
          {name:'Responsive_Search_Results5_728x90',  dimensions: [728, 90]}
      ],
      mobile: [
          {name:'Responsive_Mobile_Search_Results4_320x50',  dimensions: [320, 50]}
      ]
  }}

  let(:results_ad_slots) {{
      desktop: [
          {name:'Responsive_Search_Results2_728x90', dimensions: [728, 90]},
          {name:'Responsive_Search_Results_Text_728x60',  dimensions: [728, 60]},
          [
              {name:'Responsive_Search_Results1_300x250',  dimensions: [300, 250]},
              {name:'Responsive_Search_Results2_300x250',  dimensions: [300, 250]}
          ],
          {name:'Responsive_Search_Results3_728x90',  dimensions: [728, 90]},
          {name:'Responsive_Search_Results4_728x90',  dimensions: [728, 90]}
      ],
      mobile: [
          {name:'Responsive_Mobile_Search_Results1_300x250', dimensions: [300, 250]},
          {name:'Responsive_Mobile_Search_Results_Text_320x60',  dimensions: [320, 60]},
          {name:'Responsive_Mobile_Search_Results2_320x50',  dimensions: [320, 50]},
          {name:'Responsive_Mobile_Search_Results2_300x250',  dimensions: [320, 250]},
          {name:'Responsive_Mobile_Search_Results3_320x50',  dimensions: [320, 50]}
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
            desktop_or_mobile = slot[:name].include?('Mobile') ? 'mobile' : 'desktop'
            expect(ads_and_search_results_divs[index][:id]).to eq("ad_#{desktop_or_mobile}_#{slot[:name]}")
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
end
