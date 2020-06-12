require 'spec_helper'

describe MetricsCaching::StateMetricsCacher do
  describe '#build_hash_for_cache' do
    let(:query_results) do
      [
        double('MetricDecorator',
          label: "Percentage SAT/ACT participation grades 11-12",
          breakdown_name: "Asian",
          breakdown_tags: "ethnicity",
          value: "57.91",
          grade: "All",
          source_name: "Civil Rights Data Collection",
          subject_name:"Not Applicable",
          source_date_valid: Time.parse("2014-01-01T00:00:00-08:00"),
          year: 2014
        ),
        double('MetricDecorator',
          label: "English learners",
          breakdown_name: "All students",
          breakdown_tags: nil,
          value: "11.4579",
          grade: "All",
          source_name: "National Center for Education Statistics",
          subject_name: "Not Applicable",
          source_date_valid: Time.parse("2018-01-01T00:00:00-08:00"),
          year: 2018
        ),
        double('MetricDecorator',
          label: "4-year high school graduation rate",
          breakdown_name: "Native Hawaiian or Other Pacific Islander",
          breakdown_tags: "ethnicity",
          value: "76.5306",
          grade: "NA",
          source_name: "Colorado Department of Education",
          subject_name: "Not Applicable",
          source_date_valid: Time.parse("2017-01-01T00:00:00-08:00"),
          year: 2017
        ),
        double('MetricDecorator',
          label: "Percentage of students suspended out of school",
          breakdown_name: "Female",
          breakdown_tags: "gender",
          value: "2.94111601157535",
          grade: "All",
          source_name: "Civil Rights Data Collection",
          subject_name: "Not Applicable",
          source_date_valid: Time.parse("2016-01-01T00:00:00-08:00"),
          year: 2016
        )
      ]
    end

    subject { MetricsCaching::StateMetricsCacher.new('co') }

    before do
      allow(subject).to receive(:query_results).and_return(query_results)
      @hash = subject.build_hash_for_cache
    end

    it 'should group results by data type name' do
      expect(@hash.keys).to eq([
        'Percentage SAT/ACT participation grades 11-12',
        'English learners',
        '4-year high school graduation rate',
        'Percentage of students suspended out of school'
      ])
    end

    it 'should have expected keys and values' do
      expect(@hash['Percentage of students suspended out of school'].first).to include({
        breakdown: 'Female',
        breakdown_tags: 'gender',
        state_value: 2.94111601157535,
        grade: 'All',
        source: 'Civil Rights Data Collection',
        subject: 'Not Applicable',
        year: 2016,
        source_date_valid: Time.parse("2016-01-01T00:00:00-08:00")
      })
    end

  end
end