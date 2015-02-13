require 'spec_helper'


describe SimpleAjaxController do
  after do
    clean_models City,School
  end

  describe '#get_cities' do
    let(:cities) { FactoryGirl.build_list(:city,2) }

    it 'should return empty if no state is provided' do
      xhr :get,  :get_cities
      expect(response.body).to be_empty
    end

    it 'should return empty if invalid state is provided' do
      xhr :get,  :get_cities, state: 'foo'
      expect(response.body).to be_empty
    end

    it 'should respond respond to javascript format' do
      xhr :get,  :get_cities, state: 'sc'
      expect(response.content_type).to eq(Mime::JS)
    end

    it 'should get a list of cities in the state.' do
      state = 'sc'
      expect(City).to receive(:popular_cities).with(state).and_return(cities)
      xhr :get,  :get_cities, state: state
      expect(response.body).to_not be_emtpy
    end

  end

  describe '#get_schools' do
    let(:schools) { FactoryGirl.build_list(:school,2) }

    before(:each) do
      allow(School).to receive(:within_city).and_return(schools)
    end

    it 'should return empty if no state and city is provided' do
      xhr :get,  :get_schools
      expect(response.body).to be_empty
    end

    it 'should return empty if invalid state and city is provided' do
      xhr :get,  :get_schools, state: 'foo', city: 'bar'
      expect(response.body).to be_empty
    end

    it 'should respond to javascript format' do
      xhr :get,  :get_schools, state: 'sc', city: 'columbia'
      expect(response.content_type).to eq(Mime::JS)
    end

    it 'should get a list of schools in the city, state.' do
      state = 'sc'
      city = 'columbia'

      allow(School).to receive(:within_city).with(state,city).and_return(schools)
      # expect(School).to receive(:within_city).with(state,city).and_return(schools)
      # expect(schools).to receive(:to_a).and_call_original
      # expect(schools).to receive(:sort_by).and_call_original

      xhr :get,  :get_schools, state: state, city: city
      expect(response.body).to_not be_emtpy
    end

  end

end