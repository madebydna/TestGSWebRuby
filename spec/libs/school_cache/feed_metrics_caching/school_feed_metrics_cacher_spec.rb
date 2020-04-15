require 'spec_helper'

describe FeedMetricsCaching::SchoolFeedMetricsCacher do
  describe '#build_hash_for_cache' do
    let(:query_results) do
      [
        double('MetricDecorator',
          label: 'Enrollment',
          breakdown_name: 'All Students',
          value: '1256',
          grade: 'All',
          source_name: 'California Department of Education',
          year: 2019,
          created: '2019-12-05T19:49:52-08:00'
        ),
        double('MetricDecorator',
          label: 'Percentage of teachers in their first year',
          breakdown_name: "All students",
          created: "2020-02-05T19:49:52-08:00",
          value: '3.94737',
          grade: "NA",
          source_name: "Civil Rights Data Collection",
          year: 2012
        ),
        double('MetricDecorator',
          label: 'Ethnicity',
          breakdown_name: "Asian",
          created: "2018-12-05T19:49:52-08:00",
          value: '42.3701',
          grade: "All",
          source_name: "California Department of Education",
          year: 2019
        ),
        double('MetricDecorator',
          label: 'Ethnicity',
          breakdown_name: "Hispanic",
          created: "2018-12-05T19:49:52-08:00",
          value: '45.09',
          grade: "All",
          source_name: "California Department of Education",
          year: 2019
        ),
        double('MetricDecorator',
          label: 'Head official name',
          breakdown_name: 'All Students',
          value: 'Robert Ithurburn',
          grade: 'NA',
          source_name: 'OSP',
          year: 2020,
          created: '2019-12-05T19:49:52-08:00'
        ),
      ]
    end

    subject { FeedMetricsCaching::SchoolFeedMetricsCacher.new(double) }

    before do
      allow(subject).to receive(:query_results).and_return(query_results)
      @hash = subject.build_hash_for_cache
    end

    it 'should group results by data type name' do
      expect(@hash.keys).to eq([
        'Enrollment',
        'Percentage of teachers in their first year',
        'Ethnicity',
        'Head official name'
      ])
      expect(@hash['Ethnicity'].length).to eq(2)
    end

    it 'should have expected keys and values' do
      expect(@hash['Enrollment'].first).to eq({
        breakdown: 'All Students',
        school_value: 1256.0,
        grade: 'All',
        source: 'California Department of Education',
        year: 2019,
        created: '2019-12-05T19:49:52-08:00'
      })
    end

    it 'should convert numeric values into floats' do
      value = @hash['Percentage of teachers in their first year'].first[:school_value]
      expect(value).to eq(3.94737)
    end

    it 'should leave non-numeric values as strings' do
      value = @hash['Head official name'].first[:school_value]
      expect(value).to eq('Robert Ithurburn')
    end
  end
end