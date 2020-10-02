require 'spec_helper'

describe CachedMetricsMethods do
  class DummyClass
    attr_accessor :cache_data
    # needed for number_with_delimiter
    include ActionView::Helpers::NumberHelper
    include CachedMetricsMethods
  end

  subject { DummyClass.new }

  describe '#metrics' do
    before do
      subject.cache_data = { "metrics" => {foo: 1} }
    end

    it 'should return contents of metrics key from cache' do
      expect(subject.metrics).to eq({foo: 1})
    end
  end

  let(:enrollment_data) do
    {
      "Enrollment" => [
        {
          "breakdown" => "All students",
          "created" => "2020-02-11T16:42:26-08:00",
          "grade" => "All",
          "school_value" => 1767
        },
        {
          "breakdown" => "All students",
          "created" => "2020-02-11T16:42:26-08:00",
          "grade" => "9",
          "school_value" => 465
        }
      ]
    }
  end

  describe '#students_enrolled' do
    before do
      subject.cache_data = { "metrics" => enrollment_data }
    end

    it 'returns the formatted school_value for the Enrollment entry for all grades' do
      expect(subject.students_enrolled).to eq('1,767')
    end
  end

  describe '#numeric_enrollment' do
    before do
      subject.cache_data = { "metrics" => enrollment_data }
    end

    it 'returns the formatted school_value for the Enrollment entry for all grades' do
      expect(subject.numeric_enrollment).to eq(1767)
    end
  end

  describe '#created_time' do
    before do
      subject.cache_data = { "metrics" => enrollment_data }
    end

    it 'returns a Time object with the first created time for a valid key' do
      expect(subject.created_time('Enrollment')).to eq(Time.parse "2020-02-11T16:42:26-08:00")
    end

    it 'returns nil for invalid key' do
      expect(subject.created_time('Invalid')).to be_nil
    end
  end

  describe 'school leader methods' do
    let(:leader_data) do
      {
        "Head official email address" => [
          {
            "grade" => "NA",
            "school_value" => "rithurburn@alameda.k12.ca.us",
          }
        ],
        "Head official name" => [
          {
            "grade" => "NA",
            "school_value" => "Robert Ithurburn",
          }
        ],
      }
    end

    before { subject.cache_data = { "metrics" => leader_data } }

    it '#school_leader returns head official name' do
      expect(subject.school_leader).to eq("Robert Ithurburn")
    end

    it '#school_leader_email returns head official email' do
      expect(subject.school_leader_email).to eq("rithurburn@alameda.k12.ca.us")
    end

    it 'returns nil if data is not available' do
      subject.cache_data = { "metrics" => {} }
      expect(subject.school_leader).to be_nil
      expect(subject.school_leader_email).to be_nil
    end
  end

  describe '#enroll_in_college' do
    let(:college_enrollment_data) do
      {
        "Percent enrolled in any institution of higher learning in the last 0-16 months" => [
          {
            "breakdown" => "All students",
            "school_value" => 93,
            "state_average" => 90,
            "year" => 2016
          },
          {
            "breakdown" => "African American",
            "school_value" => 85,
            "state_average" => 73,
            "year" => 2016
          }
        ],
        "Percent Enrolled in College Immediately Following High School" => [
          {
            "breakdown": "All students",
            "school_value": 68,
            "state_average": 80,
            "year": 2015
          },
          {
            "breakdown": "Hispanic",
            "school_value": 60,
            "state_average": 60,
            "year": 2015
          }
        ]
      }
    end

    before { subject.cache_data = { "metrics" => college_enrollment_data } }

    it 'selects first school_value and state_average for all students of max overall year' do
      expect(subject.enroll_in_college).to eq({
        "school_value" => "93%",
        "state_average" => "90%"
      })
    end
  end

  describe '#stays_2nd_year' do
    let(:second_year_data) do
      {
        "Percent Enrolled in College and Returned for a Second Year" => [
          {
            "breakdown" => "All students",
            "school_value" => 59,
            "state_average" => 63,
            "year" => 2015
          },
          {
            "breakdown" => "African American",
            "school_value" => 53,
            "state_average" => 50,
            "year" => 2015
          }
        ]
      }
    end

    before { subject.cache_data = { "metrics" => second_year_data } }

    it 'seleect school_value and state average for the second year data and the all-students breakdown' do
      expect(subject.stays_2nd_year).to eq({
        "school_value" => "59%",
        "state_average" => "63%"
      })
    end
  end

  describe 'graduates remediation data' do
    let(:remediation_data) do
      {
        "Percent Needing Remediation for College" => [
          {
            "breakdown" => "All students",
            "school_value" => 31.900000,
            "subject" => "Composite Subject",
            "state_average" => 31.100000
          },
          {
            "breakdown" => "All students",
            "school_value" => 23.400000,
            "state_average" => 25.300000,
            "subject" => "Math",
          },
          {
            "breakdown" => "All students",
            "school_value" => 20.300000,
            "state_average" => 19,
            "subject" => "Writing",
          }
        ],
        "Percent needing remediation in in-state public 2-year institutions" => [
          {
            "breakdown" => "All students",
            "school_value" => 31.900000,
            "subject" => "Composite Subject",
            "state_average" => 31.100000
          },
          {
            "breakdown" => "All students",
            "school_value" => 23.400000,
            "state_average" => 25.300000,
            "subject" => "Any Subject",
          },
          {
            "breakdown" => "All students",
            "school_value" => 20.300000,
            "state_average" => 19,
            "subject" => "Science",
          }
        ]
      }
    end

    before do
      subject.cache_data = { "metrics" => remediation_data }
    end

    describe '#graduates_remediation' do
      it 'returns a hash of arrays with decorated metrics values' do
        data = subject.graduates_remediation
        expect(data).to be_a(Hash)
        expect(data["Percent Needing Remediation for College"]).to be_a(Array)
        expect(data["Percent Needing Remediation for College"][0]).to be_a(MetricsCaching::Value)
      end

      it 'removes "Composite Subject" if "Any Subject" is present' do
        data = subject.graduates_remediation["Percent needing remediation in in-state public 2-year institutions"]
        expect(data.map(&:subject)).not_to include("Composite Subject")
        expect(data.map(&:subject)).to include("Any Subject")
      end

      it 'extends each data point with the GraduatesRemediationValue module' do
        dt = subject.graduates_remediation["Percent Needing Remediation for College"].last.data_type
        expect(dt).to eq("Graduates needing Writing Remediation for College")
      end
    end

    describe '#graduates_remediation_for_college_success_awards' do
      let(:csa_data) { subject.graduates_remediation_for_college_success_awards }

      it 'for generic data type it returns data for all subjects and remediation subjects' do
        expect(csa_data["Overall"]).to eq(
          [
            {
              "data_type" => "Percent Needing Remediation for College",
              "subject" => "Composite Subject",
              "school_value" => "32%",
              "state_average" => "31%"
            },
            {
              "data_type" => "Graduates needing Math Remediation for College",
              "subject" => "Math",
              "school_value" => "23%",
              "state_average" => "25%"
            }
          ]
        )
      end

      it 'for two-year college data it only returns data for all subjects' do
        expect(csa_data["Two-year"]).to eq(
          {
            "data_type" => "Percent needing any remediation in in-state public 2-year institutions",
            "subject" => "Any Subject",
            "school_value" => "23%",
            "state_average" => "25%"
          }
        )
      end
    end
  end

  describe 'free and reduced lunch data' do
    let(:lunch_data) do
      {
        "Students participating in free or reduced-price lunch program" => [
          {
            "breakdown" => "All students",
            "created" => "2020-02-11T16:54:04-08:00",
            "district_average" => 59.400000,
            "grade" => "All",
            "school_value" => 62.600000,
            "source" => "Florida Department of Education",
            "state_average" => 69.400000,
            "subject" => "Not Applicable",
            "year" => 2018
          }
        ]
      }
    end

    before do
      subject.cache_data = { "metrics" => lunch_data }
    end

    it '#free_or_reduced_price_lunch_data returns raw data hash' do
      expect(subject.free_or_reduced_price_lunch_data).to eq(lunch_data["Students participating in free or reduced-price lunch program"])
    end

    it '#free_and_reduced_lunch returns school value only formatted as percentage' do
      expect(subject.free_and_reduced_lunch).to eq("63%")
    end
  end


end