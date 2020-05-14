require "spec_helper"

describe CommunityProfiles::CollegeReadinessComponent do
    let!(:district) { create(:district_record) }
    let(:cache_reader) {
        DistrictCacheDataReader.new(district, district_cache_keys: ['metrics', 'gsdata'])
    }
    before do
        create(:district_cache, district_id: district.district_id, state: district.state.upcase,
            name: "metrics", value: {
            "Students participating in free or reduced-price lunch program" => [
                # Entry is not included in included_data_types
                {
                    "breakdown" => "All students",
                    "district_created" => "2014-05-02T11:59:22-07:00",
                    "district_value" => 33,
                    "source" => "NCES",
                    "state_average" => 61,
                    "year" => 2018
                }
            ],
            "Percent of students who will attend in-state colleges"=> [
                # Entry is before the DATA_CUTOFF_YEAR
                {
                    "breakdown" => "All students",
                    "district_created" => "2019-02-13T11:53:58-08:00",
                    "district_value" => 38.110000,
                    "source" => "AR Dept. of Education",
                    "state_average" => 61.800000,
                    "year" => 2014
                }
            ],
            "Percent Enrolled in College Immediately Following High School" => [
                # This will get rejected because it's from 2016 and we have 2017 college success data
                {
                    "breakdown" => "All students",
                    "district_created" => "2017-06-28T22:08:22-07:00",
                    "district_value" => 65.920000,
                    "source" => "AR Dept. of Education",
                    "state_average" => 50.460000,
                    "year" => 2016
                },
                {
                    "breakdown" => "Hispanic",
                    "district_created" => "2017-06-28T22:08:23-07:00",
                    "district_value" => 46.150000,
                    "source" => "AR Dept. of Education",
                    "state_average" => 38.910000,
                    "year" => 2016
                },
                {
                    "breakdown" => "White",
                    "district_created" => "2017-06-28T22:08:20-07:00",
                    "district_value" => 67.810000,
                    "source" => "AR Dept. of Education",
                    "state_average" => 53.650000,
                    "year" => 2016
                }
            ],
            "Percent Needing Remediation for College" => [
                {
                    "breakdown" => "All students",
                    "district_created" => "2019-02-13T11:53:58-08:00",
                    "district_value" => 38.110000,
                    "source" => "AR Dept. of Education",
                    "state_average" => 61.800000,
                    "year" => 2017
                }
            ],
            "Percent enrolled in any in-state postsecondary institution within 12 months after graduation" => [
                {
                    "breakdown" => "Students with disabilities",
                    "district_created" => "2019-02-13T11:53:59-08:00",
                    "district_value" => 33.330000,
                    "source" => "AR Dept. of Education",
                    "year" => 2017
                },
                {
                    "breakdown" => "Hispanic",
                    "district_created" => "2019-02-13T11:53:59-08:00",
                    "district_value" => 68.750000,
                    "source" => "AR Dept. of Education",
                    "state_average" => 39.500000,
                    "year" => 2017
                },
                {
                    "breakdown" => "All students",
                    "district_created" => "2019-02-13T11:53:59-08:00",
                    "district_value" => 61.540000,
                    "source" => "AR Dept. of Education",
                    "state_average" => 48.200000,
                    "year" => 2017
                }
            ]
        }.to_json)
    end

    after { do_clean_models(:gs_schooldb, DistrictRecord, DistrictCache) }

    subject { CommunityProfiles::CollegeReadinessComponent.new('college_success', cache_reader) }


    context "#college_data_array" do
        let :college_success_element do
            subject.college_data_array.detect do |item|
                item[:narration] =~ /Are graduates from this district prepared to succeed in college?/
            end
        end

        it "includes college success data by college_success_datatypes" do
            college_success_by_data_types = college_success_element[:values].map {|d| d[:data_type]}
            expect(college_success_by_data_types).to include("Percent Needing Remediation for College")
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