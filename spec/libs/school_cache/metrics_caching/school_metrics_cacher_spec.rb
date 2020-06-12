require 'spec_helper'

describe MetricsCaching::SchoolMetricsCacher do
  describe '#build_hash_for_cache' do
    let(:query_results) do
      [
        double('MetricDecorator',
          label: 'Enrollment',
          breakdown_name: 'Asian',
          breakdown_tags: "ethnicity",
          value: '424',
          district_value: '5236',
          state_value: '15896',
          grade: '5',
          source_name: 'Manually entered by school official',
          subject_name: 'Not Applicable',
          year: 2019,
          source_date_valid: '2019-12-05T19:49:52-08:00',
          created: '2019-12-05T19:49:52-08:00'
        ),
        double('MetricDecorator',
          label: 'Enrollment',
          breakdown_name: 'All Students',
          breakdown_tags: "all_students",
          value: '1256',
          district_value: '10693',
          state_value: '150896',
          grade: '5',
          source_name: 'Manually entered by school official',
          subject_name: 'Not Applicable',
          year: 2019,
          source_date_valid: '2019-12-05T19:49:52-08:00',
          created: '2019-12-05T19:49:52-08:00'
        ),
        double('MetricDecorator',
          label: '4-year high school graduation rate',
          breakdown_name: "Male",
          breakdown_tags: "gender",
          created: "2018-12-05T19:49:52-08:00",
          district_value: '85.800000',
          value: '94',
          subject_name: "Not Applicable",
          grade: "Not Applicable",
          source_name: "CA Dept. of Education",
          state_value: '79.100000',
          year: 2017,
          source_date_valid: '2017-09-04T00:00:00-08:00'
        ),
        double('MetricDecorator',
          label: '4-year high school graduation rate',
          breakdown_name: "Female",
          breakdown_tags: "gender",
          created: "2018-12-05T19:49:52-08:00",
          district_value: '89.800000',
          value: '6',
          subject_name: "Not Applicable",
          grade: "Not Applicable",
          source_name: "CA Dept. of Education",
          state_value: '83.100000',
          year: 2017,
          source_date_valid: '2017-09-04T00:00:00-08:00'
        )
      ]
    end

    subject { MetricsCaching::SchoolMetricsCacher.new(double) }

    before do
      allow(subject).to receive(:query_results).and_return(query_results)
      @hash = subject.build_hash_for_cache
    end

    it 'should group results by data type name' do
      expect(@hash.keys).to eq(['Enrollment', '4-year high school graduation rate'])
    end

    it 'should have expected keys and values' do
      expect(@hash['Enrollment'].first).to include({
        breakdown: 'Asian',
        breakdown_tags: 'ethnicity',
        school_value: 424.0,
        district_average: 5236.0,
        state_average: 15896.0,
        grade: '5',
        source: 'Manually entered by school official',
        subject: 'Not Applicable',
        year: 2019,
        source_date_valid: '2019-12-05T19:49:52-08:00',
        created: '2019-12-05T19:49:52-08:00'
      })
    end
  end
end