require 'spec_helper'

describe SearchNearbyCities do
  describe '#validate_params' do
    subject(:search_nearby_cities) do
      SearchNearbyCities.new
    end
    it 'requires lat' do
      expect{subject.validate_params(lon:-122.1235)}.to raise_error ArgumentError, 'Latitude is required'
    end
    it 'requires lon' do
      expect{subject.validate_params(lat:39.9875)}.to raise_error ArgumentError, 'Longitude is required'
    end
    it 'accepts lat and lon' do
      expect{subject.validate_params(lat:39.9875,lon:-122.1235)}.not_to raise_error
    end
  end
end
