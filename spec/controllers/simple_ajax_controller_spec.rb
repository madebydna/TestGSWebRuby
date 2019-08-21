require 'spec_helper'


describe SimpleAjaxController do
  after do
    clean_models City
    clean_models :ca, School
  end

  describe '#get_cities_alphabetically' do
    let(:cities) { FactoryBot.build_list(:city,2) }

    it 'should return empty if no state is provided' do
      xhr :get,  :get_cities_alphabetically
      expect(JSON.parse(response.body)).to be_empty
    end

    it 'should return empty if invalid state is provided' do
      xhr :get,  :get_cities_alphabetically, state: 'foo'
      expect(JSON.parse(response.body)).to be_empty
    end

    it 'should respond respond to javascript format' do
      xhr :get,  :get_cities_alphabetically, state: 'in'
      expect(response.content_type).to eq(Mime::JSON)
    end

    # it 'should get a list of cities in the state.' do
    #   state = 'in'
    #   # alphabetical = 'true'
    #   # expect(City).to receive(:popular_cities).with(state).with(alphabetical).and_return(cities)
    #   # xhr :get,  :get_cities_alphabetically, state: state
    #   # expect(JSON.parse(response.body)).to eq(["Fort Wayne", "Fort Wayne"])
    # end

  end

  describe '#get_schools' do
    let(:schools) { [FactoryBot.build(:alameda_high_school,id:3),FactoryBot.build(:bay_farm_elementary_school,id:3)]}

    before(:each) do
      allow(School).to receive(:within_city).and_return(schools)
    end

    it 'should return empty if no state and city is provided' do
      xhr :get,  :get_schools_with_link
      expect(JSON.parse(response.body)).to be_empty
    end

    it 'should return empty if invalid state and city is provided' do
      xhr :get,  :get_schools_with_link, state: 'foo', city: 'bar'
      expect(JSON.parse(response.body)).to be_empty
    end

    it 'should respond to javascript format' do
      xhr :get,  :get_schools_with_link, state: 'ca', city: 'columbia'
      expect(response.content_type).to eq(Mime::JSON)
    end

    it 'should get a list of schools in the city, state.' do
      state = 'ca'
      city = 'columbia'

      expect(School).to receive(:within_city).and_return(schools)
      xhr :get,  :get_schools_with_link, state: state, city: city
      expect(JSON.parse(response.body)).to eq([{"id"=>3, "name"=>"Alameda High School", "url"=>"/california/alameda/3-Alameda-High-School/"}, {"id"=>3, "name"=>"Bay Farm Elementary School", "url"=>"/california/alameda/3-Bay-Farm-Elementary-School/"}])
    end

  end

end
