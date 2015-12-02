require 'spec_helper'
require_relative 'methodologies_examples'

describe NearbySchoolsCaching::Methodologies::ClosestSchools do

  subject { NearbySchoolsCaching::Methodologies::ClosestSchools }

  let(:main_school) do
    FactoryGirl.create(:alameda_high_school,
                       id: 1,
                       state: 'CA',
                       lat: 32,
                       lon: 144,
                       level_code: 'h'
                      )
  end
  let(:opts) do
    { limit: 3 }
  end

  # This config IS this test. Add schools here with various attributes you'd
  # like to test. If you need a completely different set, make another context.
  # To keep schools in the radius, keep their lat, lon <= 32.9, 144.9.
  # To keep things super simple, give the schools IDs in the order that you
  # would expect the query to return the schools, (see the it block).
  # There is a special exclude key that tells the spec to expect that school to
  # not be in the returned list.
  let(:school_configs) do
    [
      # Close school with high rating for just one rating type
      {
        id: 2,
        state: 'CA',
        lat: 32,
        lon: 144,
        level_code: 'h',
      },
      {
        id: 3,
        exclude: true,
        state: 'CA',
        lat: 32.6,
        lon: 144.6,
        level_code: 'h',
      },
      {
        id: 4,
        exclude: true,
        state: 'CA',
        lat: 39,
        lon: 149,
        level_code: 'e,m',
      },
      {
        id: 5,
        state: 'CA',
        exclude: true,
        lat: 39,
        lon: 149,
        level_code: 'm,h',
      },
      {
        id: 6,
        exclude: true,
        state: 'CA',
        lat: 39.0001,
        lon: 149.0001,
        level_code: 'h',
      },
      {
        id: 7,
        exclude: true,
        state: 'CA',
        lat: 33.1,
        lon: 145.1,
        level_code: 'h',
      },
      {
        id: 8,
        state: 'CA',
        lat: 32.1,
        lon: 144.1,
        level_code: 'h',
      },
      {
        id: 9,
        state: 'CA',
        lat: 32.2,
        lon: 144.2,
        level_code: 'h',
      },
    ]
  end

  before do
    school_configs.each do |config|
      FactoryGirl.create(:school_with_rating, config.except(:exclude))
    end
  end
  after do
    clean_models :ca, School, TestDataSet, TestDataSchoolValue
  end

  it 'should put schools in the correct order' do
    schools = subject.schools(main_school, opts)
    expected_ids = school_configs.select { |s| !s[:exclude] }.map do |s|
      s[:id]
    end
    expect(schools.map(&:id)).to eq(expected_ids)
  end

  include_example 'methodologies that use lat lons'
end
