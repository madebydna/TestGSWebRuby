# frozen_string_literal: true

require 'spec_helper'
require 'sitemap/sitemap_state_generator'

describe SitemapStateGenerator do
  subject(:generator) { SitemapStateGenerator.new(state) }
  let(:state) { 'nj' }

  describe '#write_state_url' do
    it 'writes out state homepage' do
      expect(generator).to receive(:write_url).with('http://localhost/new-jersey/',
                                                    SitemapStateGenerator::STATE_FREQ,
                                                    SitemapStateGenerator::STATE_PRIORITY)
      generator.send(:write_state_url)
    end
  end

  describe '#write_profile_urls' do
    before do
      school1 = double('School', canonical_url: '/california/alameda/1-Alameda-High-School/')
      school2 = double('School', id: 2, city: 'Alameda', name: 'Bay Farm', state_name: 'california')
      expect(generator).to receive(:schools).and_return([school1, school2])
    end

    it 'expects #write_url to be called with each school profile url' do
      expect(generator).to receive(:write_url).with('http://localhost/california/alameda/1-Alameda-High-School/',
                                                    SitemapStateGenerator::PROFILE_FREQ,
                                                    SitemapStateGenerator::PROFILE_PRIORITY)
      expect(generator).to receive(:write_url).with('http://localhost/california/alameda/2-Bay-Farm/',
                                                    SitemapStateGenerator::PROFILE_FREQ,
                                                    SitemapStateGenerator::PROFILE_PRIORITY)
      generator.send(:write_profile_urls)
    end
  end

  describe '#write_district_urls' do
    before do
      district1 = instance_double('District', name: 'Appoquinimink School District', city: 'Odessa')
      expect(generator).to receive(:districts).and_return([district1])
    end

    it 'expects #write_url to be called with each district url' do
      expect(generator).to receive(:write_url).with('http://localhost/new-jersey/odessa/appoquinimink-school-district/',
                                                    SitemapStateGenerator::DISTRICT_FREQ,
                                                    SitemapStateGenerator::DISTRICT_PRIORITY)
      generator.send(:write_district_urls)
    end
  end

  describe '#write_city_urls' do
    before do
      city = instance_double('City', name: 'Anchorage')
      city2 = instance_double('City', name: 'New York')
      expect(generator).to receive(:cities).and_return([city, city2])
    end

    it 'expects #write_url to be called with each city url and city browse url' do
      expect(generator).to receive(:write_url).with('http://localhost/new-jersey/anchorage/',
                                                    SitemapStateGenerator::CITY_FREQ,
                                                    SitemapStateGenerator::CITY_PRIORITY)
      expect(generator).to receive(:write_url).with('http://localhost/new-jersey/anchorage/schools/',
                                                    SitemapStateGenerator::CITY_BROWSE_FREQ,
                                                    SitemapStateGenerator::CITY_BROWSE_PRIORITY)
      expect(generator).to receive(:write_url).with('http://localhost/new-jersey/new-york/',
                                                    SitemapStateGenerator::CITY_FREQ,
                                                    SitemapStateGenerator::CITY_PRIORITY)
      expect(generator).to receive(:write_url).with('http://localhost/new-jersey/new-york/schools/',
                                                    SitemapStateGenerator::CITY_BROWSE_FREQ,
                                                    SitemapStateGenerator::CITY_BROWSE_PRIORITY)
      generator.send(:write_city_urls)
    end
  end

  describe '#schools' do
    it 'fetches all schools in state' do
      expect(School).to receive_message_chain(:on_db, :active, :order)
      generator.send(:schools)
    end
  end

  describe '#districts' do
    it 'fetches all districts in state' do
      expect(District).to receive_message_chain(:on_db, :active, :order)
      generator.send(:districts)
    end
  end

  describe '#cities' do
    it 'fetches all cities in state' do
      expect(City).to receive(:cities_in_state).with(state)
      generator.send(:cities)
    end
  end
end