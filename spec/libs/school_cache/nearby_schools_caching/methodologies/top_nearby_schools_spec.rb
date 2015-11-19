require 'spec_helper'

describe NearbySchoolsCaching::Methodologies::TopNearbySchools do

  subject { NearbySchoolsCaching::Methodologies::TopNearbySchools }

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
      limit: 5,
      radius: 100, # Large radius for testing. Choose lat, lon <= 32.9, 144.9
      ratings: [
        { data_type_id: 174, breakdown_id: 1 },
        { data_type_id: 174, breakdown_id: 8 },
      ],
      school_ids_to_exclude: '5',
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
      # Far away school with non-integer average
      {
        id: 2,
        state: 'CA',
        lat: 32.9,
        lon: 144.9,
        ratings: [
          { data_type_id: 174, breakdown_id: 1, value_float: 10 },
          { data_type_id: 174, breakdown_id: 8, value_float: 9  },
        ],
        level_code: 'h',
      },
      # Close school with high rating for just one rating type
      {
        id: 3,
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
        id: 4,
        state: 'CA',
        lat: 32.6,
        lon: 144.6,
        ratings: [
          { data_type_id: 174, breakdown_id: 1, value_float: 9 },
        ],
        level_code: 'h',
      },
      # Close school with low average rating but excluded by
      # school_ids_to_exclude param
      {
        id: 5,
        exclude: true,
        state: 'CA',
        lat: 32.1,
        lon: 144.1,
        ratings: [
          { data_type_id: 174, breakdown_id: 1, value_float: 3 },
          { data_type_id: 174, breakdown_id: 8, value_float: 1 },
        ],
        level_code: 'h',
      },
      # School with no ratings is always last, even with same location as base
      # school
      {
        id: 6,
        state: 'CA',
        lat: 32,
        lon: 144,
        level_code: 'h',
      },
      # This super far away but highly rated school should not be in the list so
      # it has the exclude key in its configuration
      {
        id: 7,
        exclude: true,
        state: 'CA',
        lat: 35,
        lon: 146,
        ratings: [
          { data_type_id: 174, breakdown_id: 1, value_float: 10 },
          { data_type_id: 174, breakdown_id: 8, value_float: 10 },
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
end
