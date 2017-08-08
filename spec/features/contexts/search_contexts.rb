require 'spec_helper'
require 'features/pages/search/search_spec_helper'
require 'features/examples/page_examples'
require 'features/page_objects/search_page'
require 'features/page_objects/city_browse_page'
include SearchSpecHelper

shared_context 'Search Page Search Bar' do
  let(:search_form_element) { page.find(:css, '.js-schoolResultsSearchForm') }
end


# Search Contexts with Solr Results Stubbed

# By Location Search Context

shared_context 'Visit By Location Search in Delaware' do
  let(:solr_results) { FactoryGirl.build(:solr_response_object) }
  let(:solr_cities_results) { FactoryGirl.build(:solr_cities_response_object) }
  let(:schools_solr_params) { FactoryGirl.build(:by_location_delaware_address_solr_params_schools) }
  let(:nearby_cities_solr_params) { FactoryGirl.build(:by_location_delaware_address_solr_params_nearby_cities) }

  before(:each) do
    allow_any_instance_of(Solr).to receive(:get_search_results).with(schools_solr_params).and_return(solr_results)
    allow_any_instance_of(Solr).to receive(:get_search_results).with(nearby_cities_solr_params).and_return(solr_cities_results)
  end
  include_context 'Visit By Location Search', *['100 North Dupont Road', 'Wilmington', 19807, 'DE', 39.752831, -75.588326]
end

# By Name Search Contexts

shared_context 'Visit By Name Search dover elementary' do
  let(:solr_results) do
    FactoryGirl.build(:solr_response_object)
  end
  let(:solr_params) { FactoryGirl.build(:by_name_solr_params_dover_schools) }

  before(:each) do
    allow_any_instance_of(Solr).to receive(:get_search_results).with(solr_params).and_return(solr_results)
  end

  include_context 'Visit By Name Search', *['dover elementary', 'DE']
end

shared_context 'Visit by name search using parameters state=de and q=north' do
  let(:solr_results) { FactoryGirl.build(:solr_response_object_north_name_search) }
  let(:schools_solr_params) { FactoryGirl.build(:by_name_solr_params_north) }

  before(:each) do
    allow_any_instance_of(Solr).to receive(:get_search_results).with(schools_solr_params).and_return(solr_results)
  end
  include_context 'Visit By Name Search', *['north', 'de']
end

shared_context 'Visit by name search using parameters state=de and q=magnolia' do
  let(:solr_results) { FactoryGirl.build(:solr_response_object_magnolia_name_search) }
  let(:schools_solr_params) { FactoryGirl.build(:by_name_solr_params_magnolia) }

  before(:each) do
    allow_any_instance_of(Solr).to receive(:get_search_results).with(schools_solr_params).and_return(solr_results)
  end
  include_context 'Visit By Name Search', *['magnolia', 'de']
end

# City Browse Search Contexts

shared_context 'Visit dover delaware city browse' do
  let(:solr_results) { FactoryGirl.build(:solr_response_object) }
  let(:solr_cities_results) { FactoryGirl.build(:solr_cities_response_object) }
  let(:schools_solr_params) { FactoryGirl.build(:city_browse_solr_params_dover_schools) }
  let(:nearby_cities_solr_params) { FactoryGirl.build(:city_browse_solr_params_dover_nearby_cities) }

  before(:each) do
    allow_any_instance_of(Solr).to receive(:get_search_results).with(nearby_cities_solr_params).and_return(solr_cities_results)
    allow_any_instance_of(Solr).to receive(:get_search_results).with(schools_solr_params).and_return(solr_results)
  end
  include_context 'Visit City Browse Search', *['de', 'Dover']
end

shared_context 'Visit youngstown ohio city browse' do
  let(:solr_results) { FactoryGirl.build(:solr_response_object) }
  let(:solr_cities_results) { FactoryGirl.build(:solr_cities_response_object) }
  let(:cities_solr_params) { FactoryGirl.build(:city_browse_ohio_solr_params_nearby_cities) }
  let(:schools_solr_params) { FactoryGirl.build(:city_browse_ohio_solr_params_schools) }

  before(:each) do
    allow_any_instance_of(Solr).to receive(:get_search_results).with(schools_solr_params).and_return(solr_results)
    allow_any_instance_of(Solr).to receive(:get_search_results).with(cities_solr_params).and_return(solr_cities_results)
  end

  include_context 'Visit City Browse Search', *['oh', 'youngstown']
end

# District Browse Search Context

shared_context 'Visit Appoquinimink  School District district browse' do
  let(:solr_results) { FactoryGirl.build(:solr_response_object) }
  let(:solr_cities_results) { FactoryGirl.build(:solr_cities_response_object) }
  let(:cities_solr_params) { FactoryGirl.build(:district_browse_delaware_solr_params_nearby_cities) }
  let(:schools_solr_params) { FactoryGirl.build(:district_browse_delaware_solr_params_schools) }

  before(:each) do
    allow_any_instance_of(Solr).to receive(:get_search_results).with(cities_solr_params).and_return(solr_cities_results)
    allow_any_instance_of(Solr).to receive(:get_search_results).with(schools_solr_params).and_return(solr_results)
  end
  include_context 'Visit District Browse Search', *['de','Appoquinimink School District','odessa'] 

end

#Compare Contexts
shared_context 'Select Schools and Go to compare' do
  include_context 'Click compare on school result number', 1
  include_context 'Click compare on school result number', 2
  include_context 'Click Compare Schools'
end

shared_context 'Click compare on school result number' do | result_number |
  before do
    school_result = page.all(:css, '.js-compareSchoolButton')[result_number - 1]
    school_result.click
    #Compare locks selecting other compare schools until the animation of the first one completes
    #Thus we may need to add a sleep to let the animation finish.
    # sleep 1
  end
end

shared_context 'Click Compare Schools' do
  before do
    # may need to add a sleep
    # sleep 1
    popup_button = page.all(:css, '.js-compareSchoolsPopupButton', visible: true).first
    popup_button.click
    submit_button = page.all(:css, '.js-compareSchoolsSubmit', visible: true).first
    submit_button.click
  end
end


shared_context 'Sorting toolbar' do
  subject { page.find(:css, '.js-sortingToolbar') }
end

shared_context 'when looking at school search results' do
  subject { page_object.school_search_results }
end

#Visiting Search Pages
shared_context 'Visit City Browse Search' do |state_abbrev, city_name, query_string=nil|
  before do
    set_up_city_browse(state_abbrev,city_name,query_string)
  end
  subject(:page_object) do
    CityBrowsePage.new
  end
end

shared_context 'Visit District Browse Search' do |state_abbrev, district_name, city_name, query_string=nil|
  before do
    set_up_district_browse(state_abbrev, district_name, city_name, query_string)
  end
  subject do
    SearchPage.new
  end
end

shared_context 'Visit By Location Search' do |address, city_name, zipcode, lat, lon, query_string=nil|
  before do
    set_up_by_location_search(address, city_name, zipcode, lat, lon, query_string)
  end
  subject do
    SearchPage.new
  end
end

shared_context 'Visit By Name Search' do |search_term, state, query_string|
  before do
    set_up_by_name_search(search_term, state, query_string)
  end
  subject(:page_object) do
    SearchPage.new
  end
end
