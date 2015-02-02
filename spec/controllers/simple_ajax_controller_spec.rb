require 'spec_helper'

describe SimpleAjaxController do

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
    end

  end

  describe '#get_schools' do
    let(:schools) { FactoryGirl.build_list(:school,2) }

    it 'should return empty if no state and city is provided' do
      xhr :get,  :get_schools
      expect(response.body).to be_empty
    end

    it 'should return empty if invalid state and city is provided' do
      xhr :get,  :get_schools, state: 'foo', city: 'bar'
      expect(response.body).to be_empty
    end

    it 'should respond respond to javascript format' do
      xhr :get,  :get_schools, state: 'sc', city: 'columbia'
      expect(response.content_type).to eq(Mime::JS)
    end

    it 'should get a list of schools in the city, state.' do
      state = 'sc'
      city = 'columbia'
      expect(School).to receive(:within_city).with(state,city).and_return(schools)
      xhr :get,  :get_schools, state: state, city: city
    end

  end

end