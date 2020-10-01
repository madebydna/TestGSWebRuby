require "spec_helper"

describe CommunityProfiles::CollegeReadinessComponent do
  let!(:district) { create(:district_record) }
  let(:cache_reader) {
    DistrictCacheDataReader.new(district, district_cache_keys: ['metrics'])
  }
  before do
    create(:district_cache, district_id: district.district_id, state: district.state.upcase,
      name: "metrics", value: {
      "Students participating in free or reduced-price lunch program" => [
        # Entry is not included in included_data_types
        {
          "breakdown" => "All students",
          "created" => "2014-05-02T11:59:22-07:00",
          "district_value" => 33,
          "source" => "NCES",
          "state_average" => 61,
          "year" => 2018,
          "subject" => "Not Applicable",
          "source_date_valid" => "2018-01-01T00:00:00-07:00"
        }
      ],
      "Percent of students who will attend in-state colleges"=> [
        # Entry is before the DATA_CUTOFF_YEAR
        {
          "breakdown" => "All students",
          "created" => "2019-02-13T11:53:58-08:00",
          "district_value" => 38.110000,
          "source" => "AR Dept. of Education",
          "state_average" => 61.800000,
          "subject" => "Not Applicable",
          "year" => 2014,
          "source_date_valid" => "2014-01-01T00:00:00-07:00"
        }
      ],
      "Percent Enrolled in College Immediately Following High School" => [
          # This will get rejected because it's from 2016 and we have 2017 college success data
          {
            "breakdown" => "All students",
            "created" => "2017-06-28T22:08:22-07:00",
            "district_value" => 65.920000,
            "source" => "AR Dept. of Education",
            "state_average" => 50.460000,
            "year" => 2016,
            "subject" => "Not Applicable",
            "source_date_valid" => "2016-01-01T00:00:00-07:00"
          },
          {
            "breakdown" => "Hispanic",
            "created" => "2017-06-28T22:08:23-07:00",
            "district_value" => 46.150000,
            "source" => "AR Dept. of Education",
            "state_average" => 38.910000,
            "year" => 2016,
            "subject" => "Not Applicable",
            "source_date_valid" => "2016-01-01T00:00:00-07:00"
          },
          {
            "breakdown" => "White",
            "created" => "2017-06-28T22:08:20-07:00",
            "district_value" => 67.810000,
            "source" => "AR Dept. of Education",
            "state_average" => 53.650000,
            "year" => 2016,
            "subject" => "Not Applicable",
            "source_date_valid" => "2016-01-01T00:00:00-07:00"
          }
      ],
      "Percent Needing Remediation for College" => [
        {
          "breakdown" => "All students",
          "created" => "2019-02-13T11:53:58-08:00",
          "district_value" => 38.110000,
          "source" => "AR Dept. of Education",
          "state_average" => 61.800000,
          "year" => 2017,
          "subject" => "Composite Subject",
          "source_date_valid" => "2016-01-01T00:00:00-07:00"
        },
        {
          "breakdown" => "All students",
          "created" => "2019-02-13T11:53:58-08:00",
          "district_value" => 38.110000,
          "source" => "AR Dept. of Education",
          "state_average" => 61.800000,
          "year" => 2017,
          "subject" => "Any Subject",
          "source_date_valid" => "2016-01-01T00:00:00-07:00"
        },
        {
          "breakdown" => "All students",
          "created" => "2019-02-13T11:53:58-08:00",
          "district_value" => 42.110000,
          "source" => "AR Dept. of Education",
          "state_average" => 70.800000,
          "year" => 2017,
          "subject" => "Math",
          "source_date_valid" => "2016-01-01T00:00:00-07:00"
        }
      ],
      "Percent enrolled in any in-state postsecondary institution within 12 months after graduation" => [
        {
          "breakdown" => "Students with disabilities",
          "created" => "2019-02-13T11:53:59-08:00",
          "district_value" => 33.330000,
          "source" => "AR Dept. of Education",
          "year" => 2017,
          "subject" => "Not Applicable",
          "source_date_valid" => "2017-01-01T00:00:00-07:00"
        },
        {
          "breakdown" => "Hispanic",
          "created" => "2019-02-13T11:53:59-08:00",
          "district_value" => 68.750000,
          "source" => "AR Dept. of Education",
          "state_average" => 39.500000,
          "year" => 2017,
          "subject" => "Not Applicable",
          "source_date_valid" => "2017-01-01T00:00:00-07:00"
        },
        {
          "breakdown" => "All students",
          "created" => "2019-02-13T11:53:59-08:00",
          "district_value" => 61.540000,
          "source" => "AR Dept. of Education",
          "state_average" => 48.200000,
          "year" => 2017,
          "subject" => "Not Applicable",
          "source_date_valid" => "2017-01-01T00:00:00-07:00"
        }
      ]
    }.to_json)
  end

  after { do_clean_models(:gs_schooldb, DistrictRecord, DistrictCache) }

  subject { CommunityProfiles::CollegeReadinessComponent.new('college_success', cache_reader) }

  context "#metrics_data" do
    let(:metrics_data) { subject.metrics_data }
    it "changes college remediation data type to be subject-specific" do
      metric = metrics_data["Percent Needing Remediation for College"].last
      expect(metric.data_type).to eq("Graduates needing Math Remediation for College")
    end

    it "does not contain data type for college remediation with Composite Subject" do
      metric = metrics_data["Percent Needing Remediation for College"].detect {|m| m.subject == 'Composite Subject'}
      expect(metric).to be nil
    end

    it "changes college remediation data type for college remediation with Any Subject" do
      metric = metrics_data["Percent Needing Remediation for College"].detect {|m| m.subject == 'Any Subject'}
      expect(metric.data_type).to eq("Percent Needing any Remediation for College")
    end

    it "maintains original data type for non-college-remediation data" do
      metric = metrics_data["Percent of students who will attend in-state colleges"].first
      expect(metric.data_type).to eq("Percent of students who will attend in-state colleges")
    end
  end

  context "#college_data_array" do
    let :college_success_element do
      subject.college_data_array.detect do |item|
        item[:narration] =~ /Are graduates from this district prepared to succeed in college?/
      end
    end

    it "includes college success data by college_success_datatypes" do
      college_success_by_data_types = college_success_element[:values].map {|d| d[:data_type]}
      expect(college_success_by_data_types).to include("Percent Needing any Remediation for College")
      expect(college_success_by_data_types).to include("Percent enrolled in any in-state postsecondary institution within 12 months after graduation")
    end

    it "includes only college success entries for the 'all students' breakdown" do
      mapped_by_subgroup = college_success_element[:values].map {|h| h[:subgroup]}
      expect(mapped_by_subgroup.uniq).to eq(["All students"])
    end
  end


  context "#data_type_hashes" do
    let(:mapped_data_types) { subject.data_type_hashes.map(&:data_type) }

    # This is where most of the filtering happens
    it "rejects values earlier than DATA_CUTOFF_YEAR" do
      # DATA_CUTOFF_YEAR is 2015
      expect(mapped_data_types).not_to include("Percent of students who will attend in-state colleges")
    end
    it "only accepts values from POST_SECONDARY group that match max year within the group" do
      # 2016 entries will be rejected since we have 2017 data
      expect(mapped_data_types).not_to include("Percent Enrolled in College Immediately Following High School")
    end
    it "reject entries not matching the college_success data types" do
      expect(subject.included_data_types).not_to include("Students participating in free or reduced-price lunch program")
      expect(mapped_data_types).not_to include("Students participating in free or reduced-price lunch program")
    end
  end
end