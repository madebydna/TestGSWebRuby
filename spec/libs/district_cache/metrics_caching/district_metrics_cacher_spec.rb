require 'spec_helper'

describe MetricsCaching::DistrictMetricsCacher do
  describe '#build_hash_for_cache' do
    let(:query_results) do
      [
        double('MetricDecorator',
          label: "Enrollment",
          breakdown_name: "All students",
          value: "434",
          state_value: "123456",
          grade: "UG",
          breakdown_tags: "all_students",
          source_name: "National Center for Education Statistics",
          subject_name: "Not Applicable",
          year: 2018,
          source_date_valid: 'Mon, 01 Jan 2018 00:00:00 PST -08:00',
          created: 'Tue, 11 Feb 2020 16:57:16 PST -08:00'),
        double('MetricDecorator',
          label: "Enrollment",
          breakdown_name: "All students",
          value: "14425",
          grade: "6",
          state_value: "75,456",
          breakdown_tags: "all_students",
          source_name: "National Center for Education Statistics",
          subject_name: "Not Applicable",
          year: 2018,
          source_date_valid: 'Mon, 01 Jan 2018 00:00:00 PST -08:00',
          created: 'Tue, 11 Feb 2020 16:57:16 PST -08:00'),
        double('MetricDecorator',
          label: "Percent of Psychologist Staff",
          breakdown_name: "no staff",
          value: "100",
          state_value: "86.778",
          subject_name: "Not Applicable",
          grade: "All",
          breakdown_tags: nil,
          source_name: "Civil Rights Data Collection",
          year: 2016,
          source_date_valid: 'Fri, 01 Jan 2016 00:00:00 PST -08:00',
          created: 'Tue, 27 Aug 2019 22:32:21 PDT -07:00'),
        double('MetricDecorator',
          label: "Percentage of students enrolled in Dual Enrollment classes grade 9-12",
          breakdown_name: "Native American",
          value: "9.23076923076923",
          state_value: "23.34",
          grade: "All",
          subject_name: "Not Applicable",
          breakdown_tags: "ethnicity",
          source_name: "Civil Rights Data Collection",
          year: 2016,
          source_date_valid: 'Fri, 01 Jan 2016 00:00:00 PST -08:00',
          created: 'Wed, 14 Aug 2019 10:07:59 PDT -07:00')
      ]
    end

    subject { MetricsCaching::DistrictMetricsCacher.new(double) }

    before do
      allow(subject).to receive(:query_results).and_return(query_results)
      @hash = subject.build_hash_for_cache
    end

    it 'should group results by data type name' do
      expect(@hash.keys).to eq(['Enrollment', 'Percent of Psychologist Staff', 'Percentage of students enrolled in Dual Enrollment classes grade 9-12'])
    end

    it 'should have expected keys and values' do
      expect(@hash['Enrollment'].first).to include({
        breakdown: 'All students',
        breakdown_tags: 'all_students',
        district_value: 434.0,
        state_average: 123_456.0,
        grade: 'UG',
        source: 'National Center for Education Statistics',
        subject: 'Not Applicable',
        year: 2018,
        source_date_valid: 'Mon, 01 Jan 2018 00:00:00 PST -08:00',
        district_created: 'Tue, 11 Feb 2020 16:57:16 PST -08:00'
      })
    end

  end
end