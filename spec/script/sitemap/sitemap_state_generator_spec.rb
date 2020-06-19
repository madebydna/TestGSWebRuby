# frozen_string_literal: true

require 'spec_helper'
require 'sitemap/sitemap_state_generator'

describe SitemapStateGenerator do
  subject(:generator) { SitemapStateGenerator.new('.', state) }
  let(:state) { 'nj' }
  after do
    clean_dbs :_ca
  end

  describe '#write_state_url' do
    it 'writes out state homepage' do
      expect(generator).to receive(:write_url).with('https://www.greatschools.org/new-jersey/',
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
      expect(generator).to receive(:write_url).with('https://www.greatschools.org/california/alameda/1-Alameda-High-School/',
                                                    SitemapStateGenerator::PROFILE_FREQ,
                                                    SitemapStateGenerator::PROFILE_PRIORITY)
      expect(generator).to receive(:write_url).with('https://www.greatschools.org/california/alameda/2-Bay-Farm/',
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
      expect(generator).to receive(:write_url).with('https://www.greatschools.org/new-jersey/odessa/appoquinimink-school-district/',
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
      expect(generator).to receive(:write_url).with('https://www.greatschools.org/new-jersey/anchorage/',
                                                    SitemapStateGenerator::CITY_FREQ,
                                                    SitemapStateGenerator::CITY_PRIORITY)
      expect(generator).to receive(:write_url).with('https://www.greatschools.org/new-jersey/anchorage/schools/',
                                                    SitemapStateGenerator::CITY_BROWSE_FREQ,
                                                    SitemapStateGenerator::CITY_BROWSE_PRIORITY)
      expect(generator).to receive(:write_url).with('https://www.greatschools.org/new-jersey/new-york/',
                                                    SitemapStateGenerator::CITY_FREQ,
                                                    SitemapStateGenerator::CITY_PRIORITY)
      expect(generator).to receive(:write_url).with('https://www.greatschools.org/new-jersey/new-york/schools/',
                                                    SitemapStateGenerator::CITY_BROWSE_FREQ,
                                                    SitemapStateGenerator::CITY_BROWSE_PRIORITY)
      generator.send(:write_city_urls)
    end
  end

  describe '#schools' do
    let(:school) { create(:school) }
    let(:same_school_with_different_attributes) do
      new_school = school.clone
      new_school.assign_attributes(district_id: 15, city: 'Andyville', state: 'CA')
      new_school
    end

    describe '#active_schools' do
      it 'fetches all schools in state' do
        expect(School).to receive_message_chain(:on_db, :active, :order)
        generator.send(:active_schools)
      end
    end

    describe '#schools_to_no_index' do
      it 'fetches all no index schools in state' do
        expect(School).to receive_message_chain(:active, :joins, :select, :where, :where, :where, :where, :group, :having)
        generator.send(:schools_to_no_index)
      end
    end

    it 'returns the expect active record collection' do
      allow(generator).to receive(:schools_to_no_index).and_return([same_school_with_different_attributes])
      allow(generator).to receive(:active_schools).and_return([school])
      expect(generator.send(:schools)).to eq([])
    end
  end

  describe '#districts' do
    it 'fetches all districts in state' do
      expect(DistrictRecord).to receive_message_chain(:by_state, :order)
      generator.send(:districts)
    end
  end

  describe '#cities' do
    context 'with two cities having 3 or more active schools' do
      before do
        city1 = instance_double('City', name: '1')
        city2 = instance_double('City', name: '2')
        city3 = instance_double('City', name: '3')
        city4 = instance_double('City', name: '4')
        city5 = instance_double('City', name: '5')

        expect(City).to receive(:cities_in_state).with(state).and_return([city1, city2, city3, city4, city5])

        schools1 = double(count: 0)
        schools2 = double(count: 1)
        schools3 = double(count: 2)
        schools4 = double(count: 3)
        schools5 = double(count: 145)
        [city1, schools1,
         city2, schools2,
         city3, schools3,
         city4, schools4,
         city5, schools5].each_slice(2) do |city, school_relation|
          expect(School).to receive(:within_city).with(state, city.name).and_return(school_relation)
          expect(school_relation).to receive(:count).and_return(school_relation.count)
        end
      end

      context 'the number of cities returned' do
        subject { generator.send(:cities).size }

        it { is_expected.to eq(2) }
      end
    end
  end
end