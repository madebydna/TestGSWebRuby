require 'spec_helper'
require_relative 'methodologies_examples'

describe NearbySchoolsCaching::Methodologies::ClosestTopSchools do

  subject { NearbySchoolsCaching::Methodologies::ClosestTopSchools }

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
    {
      limit: 3,
      minimum: 8,
      ratings: [
        { data_type_id: 174, breakdown_id: 1 },
        { data_type_id: 174, breakdown_id: 8 },
      ]
    }
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
        lat: 32.1,
        lon: 144.1,
        ratings: [
          { data_type_id: 174, breakdown_id: 8, value_float: 9 },
        ],
        level_code: 'h',
      },
      # Same rating as above school but further away
      {
        id: 3,
        state: 'CA',
        lat: 32.6,
        lon: 144.6,
        ratings: [
          { data_type_id: 174, breakdown_id: 1, value_float: 9 },
        ],
        level_code: 'h',
      },
      # Highly rated school, but the wrong level_code
      {
        id: 4,
        exclude: true,
        state: 'CA',
        lat: 39,
        lon: 149,
        ratings: [
          { data_type_id: 174, breakdown_id: 1, value_float: 10 },
          { data_type_id: 174, breakdown_id: 8, value_float: 8  },
        ],
        level_code: 'e,m',
      },
      # Highest rated school, but further away
      {
        id: 5,
        state: 'CA',
        lat: 39,
        lon: 149,
        ratings: [
          { data_type_id: 174, breakdown_id: 1, value_float: 10 },
          { data_type_id: 174, breakdown_id: 8, value_float: 9  },
        ],
        level_code: 'm,h',
      },
      # This school makes the cut (almost identical to the one above it) but is
      # excluded because of the limit param
      {
        id: 6,
        exclude: true,
        state: 'CA',
        lat: 39.0001,
        lon: 149.0001,
        ratings: [
          { data_type_id: 174, breakdown_id: 1, value_float: 10 },
          { data_type_id: 174, breakdown_id: 8, value_float: 9  },
        ],
        level_code: 'h',
      },
      # Close school with high average, but cut because has a 7 for a rating
      {
        id: 7,
        exclude: true,
        state: 'CA',
        lat: 32.1,
        lon: 144.1,
        ratings: [
          { data_type_id: 174, breakdown_id: 1, value_float: 10 },
          { data_type_id: 174, breakdown_id: 8, value_float: 7 },
        ],
        level_code: 'h',
      },
      # School with no ratings should not be in list
      {
        id: 8,
        exclude: true,
        state: 'CA',
        lat: 32,
        lon: 144,
        level_code: 'h',
      },
      # This super close but low rated school should not be in the list
      {
        id: 9,
        exclude: true,
        state: 'CA',
        lat: 32,
        lon: 144,
        ratings: [
          { data_type_id: 174, breakdown_id: 1, value_float: 1 },
          { data_type_id: 174, breakdown_id: 8, value_float: 1 },
        ],
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
