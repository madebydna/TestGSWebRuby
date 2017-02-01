require 'spec_helper'

describe WidgetController do
  # let!(:widget_controller) { instance_double(WidgetController) }

  [GoogleMapConcerns].each do | mod |
    it 'should include #{mod.to_s}' do
      expect(WidgetController.ancestors.include?(mod)).to be_truthy
    end
  end

  describe '#widget_map should serve these methods based on parameters' do

    context 'when user requests widget' do
      it 'it should still show with no params' do
        params = {}
        get :map, params
        expect(response).to render_template(:map)
      end
    end

    context 'when only lat, lon as params' do
      it 'should call by_location' do
        params = {:lat => '1', :lon => '1'}
        allow(controller).to receive(:by_location).and_return(true)
        expect(controller).to receive(:by_location)
        get :map, params
      end
    end

    context 'when searchQuery as param' do
      before(:each) { create(:city, name: 'San Francisco', state: 'CA') }
      before(:each) { BpZip.create(Zip: '94111', Name: 'San Francisco', State: 'CA', Lat: 37.7988, Lon: -122.401) }
      after(:each) { clean_dbs :us_geo }

      it 'when empty it should call by_location' do
        params = {:lat => '1', :lon => '1', :searchQuery => ''}
        allow(controller).to receive(:by_location).and_return(true)
        expect(controller).to receive(:by_location)
        get :map, params
      end

      it 'should call by_name city and state in queryString' do
        params = {:searchQuery => 'San Francisco, CA'}
        expect(controller).to receive(:city_from_searchQuery_split_two_segment)
        get :map, params
      end

      it 'should call by_name city and state in queryString to city_browse' do
        params = {:searchQuery => 'San Francisco, CA'}
        allow(controller).to receive(:city_browse).and_return(true)
        expect(controller).to receive(:city_browse)
        get :map, params
      end

      it 'should call by_name single unique city in queryString' do
        params = {:searchQuery => 'San Francisco'}
        expect(controller).to receive(:city_from_searchQuery_split_one_segment)
        get :map, params
      end

      it 'should call by_name single unique city in queryString to city_browse' do
        params = {:searchQuery => 'San Francisco'}
        allow(controller).to receive(:city_browse).and_return(true)
        expect(controller).to receive(:city_browse)
        get :map, params
      end

      it 'should call by zip and return city' do
        params = {:searchQuery => '94111'}
        expect(controller).to receive(:city_from_searchQuery_zip)
        get :map, params
      end

      it 'should call by zip and return city to city_browse' do
        params = {:searchQuery => '94111'}
        allow(controller).to receive(:city_browse).and_return(true)
        expect(controller).to receive(:city_browse)
        get :map, params
      end

      it 'should call by cityName and state' do
        params = {:cityName => 'San Francisco', :state => 'CA'}
        expect(controller).to receive(:city_from_params_cityName_state)
        get :map, params
      end

      it 'should call by cityName and state to city_browse' do
        params = {:cityName => 'San Francisco', :state => 'CA'}
        allow(controller).to receive(:city_browse).and_return(true)
        expect(controller).to receive(:city_browse)
        get :map, params
      end

    end
  end
end