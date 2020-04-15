require 'spec_helper'

describe FeedMetricsCaching::DistrictFeedMetricsCacher do
  describe '#build_hash_for_cache' do
    let(:query_results) do
      [
        double('MetricDecorator',
          label: 'English learners',
          breakdown_name: 'All students',
          value: '14.2603',
          grade: 'All',
          source_name: 'California Department of Education',
          year: 2019,
          created: '2020-02-11T23:15:52-08:00'
        ),
        double('MetricDecorator',
          label: 'Enrollment',
          breakdown_name: 'All students',
          created: "2018-12-05T19:49:52-08:00",
          value: '865',
          grade: "7",
          source_name: "California Department of Education",
          year: 2019
        ),
        double('MetricDecorator',
          label: 'Enrollment',
          breakdown_name: 'All students',
          created: "2018-12-05T19:49:52-08:00",
          value: '846',
          grade: "6",
          source_name: "California Department of Education",
          year: 2019
        ),
        double('MetricDecorator',
          label: 'Head official email address',
          breakdown_name: 'All students',
          value: 'smcphetridge@alameda.k12.ca.us',
          grade: 'NA',
          source_name: 'California Department of Education',
          year: 2015,
          created: '2020-02-22T19:49:52-08:00'
        ),
      ]
    end

    subject { FeedMetricsCaching::DistrictFeedMetricsCacher.new(double) }

    before do
      allow(subject).to receive(:query_results).and_return(query_results)
      @hash = subject.build_hash_for_cache
    end

    it 'should group results by data type name' do
      expect(@hash.keys).to eq([
        'English learners',
        'Enrollment',
        'Head official email address'
      ])
      expect(@hash['Enrollment'].length).to eq(2)
    end

    it 'should have expected keys and values' do
      expect(@hash['Enrollment'].first).to eq({
        breakdown: 'All students',
        district_value: 865.0,
        grade: '7',
        source: 'California Department of Education',
        year: 2019,
        district_created: '2018-12-05T19:49:52-08:00'
      })
    end

    it 'should convert numeric values into floats' do
      value = @hash['English learners'].first[:district_value]
      expect(value).to eq(14.2603)
    end

    it 'should leave non-numeric values as strings' do
      value = @hash['Head official email address'].first[:district_value]
      expect(value).to eq('smcphetridge@alameda.k12.ca.us')
    end
  end
end