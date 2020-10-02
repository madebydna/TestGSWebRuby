require 'spec_helper'

describe MetricsCaching::Value do
  let(:hash) do
    {
      "breakdown_tags" => "ethnicity",
      "breakdown" => "African American",
      "subject" => "Not Applicable",
      "state_value" => "23.3445",
      "source_date_valid" => "2017-01-01T00:00:00-08:00",
      "year" => 2017,
      "source" => "California Department of Education",
      "grade" => "NA"
    }
  end

  it 'should have .from_hash class method' do
    expect(MetricsCaching::Value).to respond_to(:from_hash)
  end

  subject { MetricsCaching::Value.from_hash(hash)  }

  describe '.from_hash' do
    it 'creates attributes for all hash keys that have matching accessors' do
      expect(subject.breakdown_tags).to eq("ethnicity")
      expect(subject.breakdown).to eq("African American")
      expect(subject.subject).to eq("Not Applicable")
      expect(subject.state_value).to eq("23.3445")
      expect(subject.source_date_valid).to eq("2017-01-01T00:00:00-08:00")
      expect(subject.year).to eq(2017)
      expect(subject.source).to eq("California Department of Education")
      expect(subject.grade).to eq("NA")
    end
  end

  describe 'hash accessors' do
    it 'should allow accessing attributes as hash keys' do
      expect(subject["breakdown_tags"]).to eq("ethnicity")
      expect(subject["breakdown"]).to eq("African American")
      expect(subject["subject"]).to eq("Not Applicable")
      expect(subject["state_value"]).to eq("23.3445")
      expect(subject["source_date_valid"]).to eq("2017-01-01T00:00:00-08:00")
      expect(subject["year"]).to eq(2017)
      expect(subject["source"]).to eq("California Department of Education")
      expect(subject["grade"]).to eq("NA")
    end
  end

  describe '#source_year' do
    it 'should return year value if present' do
      expect(subject.source_year).to eq(subject.year)
    end

    it 'should fall back to year from source_date_valid if year not present' do
      subject.year = nil
      expect(subject.source_year).to eq(2017)
    end
  end

  it '#school_value_as_int should return school_value as integer' do
    subject.school_value = "12.345"
    expect(subject.school_value_as_int).to eq(12)
  end

  it '#school_value_as_int should return nil if school_value is missing' do
    expect(subject.school_value_as_int).to be nil
  end

  it '#school_value_as_float should return school_value as float' do
    subject.school_value = "12.345"
    expect(subject.school_value_as_float).to eq(12.345)
  end

  it '#district_value_as_float should return district_value as float' do
    subject.district_value = "12.345"
    expect(subject.district_value_as_float).to eq(12.345)
  end

  it '#state_value_as_float should return state_value as float' do
    subject.state_value = "12.345"
    expect(subject.state_value_as_float).to eq(12.345)
  end

  describe '#grade_all?' do
    it 'should return true if grade is All' do
      subject.grade = "All"
      expect(subject.grade_all?).to be true
    end
    it 'should return true if grade is NA' do
      subject.grade = "NA"
      expect(subject.grade_all?).to be true
    end
    it 'should return false for a particular grade' do
      subject.grade = "6"
      expect(subject.grade_all?).to be false
    end
  end

  describe "#all_students?" do
    it 'should return true breakdown is blank' do
      subject.breakdown = nil
      expect(subject.all_students?).to be true
    end
    it 'should return true with breakdown \'All students\'' do
      subject.breakdown = "All students"
      expect(subject.all_students?).to be true
    end
    it 'should return false for other breakdown' do
      subject.breakdown = "Asian"
      expect(subject.all_students?).to be false
    end
  end

  describe "#all_subjects?" do
    it "should return true subject is 'Not Applicable'"  do
      subject.subject = "Not Applicable"
      expect(subject.all_subjects?).to be true
    end
    it "should return true subject is 'Composite Subject'" do
      subject.subject = "Composite Subject"
      expect(subject.all_subjects?).to be true
    end
    it "should return true subject is 'Any Subject'" do
      subject.subject = "Any Subject"
      expect(subject.all_subjects?).to be true
    end
    it "should return false if subject is a valid subject" do
      subject.subject = "Reading"
      expect(subject.all_subjects?).to be false
    end
  end

  describe "#all_subjects_and_students?" do
    it 'should return true if both all subjects and students is true' do
      subject.subject = "Composite Subject"
      subject.breakdown = "All students"
      expect(subject.all_subjects_and_students?).to be true
    end

    it 'should return false if subject is Math and breakdown is All students' do
      subject.subject = "Math"
      subject.breakdown = "All students"
      expect(subject.all_subjects_and_students?).to be false
    end

    it 'should return false for Composite Subject and breakdown African American' do
      subject.subject = "Composite Subject"
      subject.breakdown = "African American"
      expect(subject.all_subjects_and_students?).to be false
    end
  end

  it "#has_ethnicity_tag? returns true for ethnicity breakdown_tags" do
    subject.breakdown_tags = 'ethnicity'
    expect(subject.has_ethnicity_tag?).to be true
  end

  describe MetricsCaching::Value::CollectionMethods do

    it "#for_all_students should return an array of values with breakdown 'All students'" do
      data = [
        hash.merge({"breakdown" => "All students"}),
        hash.merge({"breakdown" => "All students"}),
        hash.merge({"breakdown" => "African American"})
      ]

      result = create_collection(data)
      expect(result.for_all_students).to contain_exactly(result[0], result[1])
    end

    it "#any_subgroups? should return true if array contains any values with specific breakdown" do
      data = [
        hash.merge({"breakdown" => "All students"}),
        hash.merge({"breakdown" => "All students"}),
        hash.merge({"breakdown" => "Asian"})
      ]

      result = create_collection(data)
      expect(result.any_subgroups?).to be true
    end

    it "#having_district_value should filter for records with a district_value" do
      data = [
        hash.merge({"district_value" => "123.45"}),
        hash.except("district_value"),
        hash.merge({"district_value" => "16.4"})
      ]

      result = create_collection(data)
      expect(result.having_district_value).to contain_exactly(result[0], result[2])
    end

    it "#having_school_value should filter for records with a school_value" do
      data = [
        hash.merge({"school_value" => "123.45"}),
        hash.except("school_value"),
        hash.merge({"school_value" => "16.4"})
      ]

      result = create_collection(data)
      expect(result.having_school_value).to contain_exactly(result[0], result[2])
    end

    it "#having_non_zero_school_value should filter for records with a non zero school_value" do
      data = [
        hash.merge({"school_value" => "123.45"}),
        hash.except("school_value"),
        hash.merge({"school_value" => nil}),
        hash.merge({"school_value" => "0"}),
        hash.merge({"school_value" => "0.234"}),
        hash.merge({"school_value" => "1.045"}),
      ]

      result = create_collection(data)
      expect(result.having_non_zero_school_value).to contain_exactly(result[0], result[4], result[5])
    end

    it "#most_recent should select the record with the most recent date stamp" do
      data = [
        hash.merge({"source_date_valid" => "2017-01-01T00:00:00-08:00"}),
        hash.merge({"source_date_valid" => "2016-01-01T00:00:00-08:00"}),
        hash.merge({"source_date_valid" => "2017-07-01T00:00:00-08:00"}),
        hash.merge({"source_date_valid" => "2015-01-01T00:00:00-08:00"})
      ]
      result = create_collection(data)
      expect(result.most_recent).to eq(result[2])
    end

    it "#having_most_recent_date should remove older records" do
      data = [
        hash.merge({"source_date_valid" => "2017-01-01T00:00:00-08:00"}),
        hash.merge({"source_date_valid" => "2016-01-01T00:00:00-08:00"}),
        hash.merge({"source_date_valid" => "2017-01-01T00:00:00-08:00"}),
        hash.merge({"source_date_valid" => "2015-01-01T00:00:00-08:00"})
      ]
      result = create_collection(data)
      expect(result.having_most_recent_date).to contain_exactly(result[0], result[2])
    end

    it "#most_recent_source_year returns most recent year" do
      data = [
        hash.merge({"source_date_valid" => "2017-01-01T00:00:00-08:00"}),
        hash.merge({"source_date_valid" => "2016-01-01T00:00:00-08:00"}),
        hash.merge({"source_date_valid" => "2017-01-01T00:00:00-08:00"}),
        hash.merge({"source_date_valid" => "2015-01-01T00:00:00-08:00"})
      ]
      result = create_collection(data)
      expect(result.most_recent_source_year).to eq(2017)
    end


    it "#recent_ethnicity_school_values return most recent ethnicity records that have a school_value" do
      data = [
        hash.merge({"source_date_valid" => "2017-01-01T00:00:00-08:00", "breakdown_tags" => "ethnicity", "school_value" => nil}),
        hash.merge({"source_date_valid" => "2017-01-01T00:00:00-08:00", "breakdown_tags" => "ethnicity", "school_value" => "2.334"}),
        hash.merge({"source_date_valid" => "2016-01-01T00:00:00-08:00", "breakdown_tags" => "ethnicity", "school_value" => "1.233"}),
        hash.merge({"source_date_valid" => "2017-01-01T00:00:00-08:00", "breakdown_tags" => "gender", "school_value" => "1.233"}),
        hash.merge({"source_date_valid" => "2015-01-01T00:00:00-08:00", "breakdown_tags" => "ethnicity", "school_value" => "1.233"})
      ]
      result = create_collection(data)
      expect(result.recent_ethnicity_school_values).to contain_exactly(result[1])
    end

    it "#recent_students_with_disabilities_school_values selects most recent disability records that have a school value" do
      data = [
        hash.merge({"source_date_valid" => "2017-01-01T00:00:00-08:00", "breakdown" => "Asian", "school_value" => "34.455"}),
        hash.merge({"source_date_valid" => "2017-01-01T00:00:00-08:00", "breakdown" => "Students with disabilities", "school_value" => "2.334"}),
        hash.merge({"source_date_valid" => "2016-01-01T00:00:00-08:00", "breakdown" => "Students with disabilities", "school_value" => "1.233"}),
        hash.merge({"source_date_valid" => "2017-01-01T00:00:00-08:00", "breakdown" => "Students with IDEA catagory disabilities", "school_value" => "1.233"}),
        hash.merge({"source_date_valid" => "2015-01-01T00:00:00-08:00", "breakdown" => "African American", "school_value" => "1.233"})
      ]

      result = create_collection(data)
      expect(result.recent_students_with_disabilities_school_values).to contain_exactly(result[1], result[3])
    end

    it "#no_subject_or_all_subjects_or_graduates_remediation select all-subject records or those with remediation data type" do
      data = [
        hash.merge({"subject" => "Composite Subject", "data_type" => "Enrollment"}),
        hash.merge({"subject" => "Composite Subject", "data_type" => "Percent Needing Remediation for College"}),
        hash.merge({"subject" => "Math", "data_type" => "Graduates needing Writing Remediation for College"}),
        hash.merge({"subject" => "Math", "data_type" => "Enrollment"}),
        hash.merge({"subject" => "Any Subject", "data_type" => "Percent needing any remediation in in-state public 2-year institutions"})
      ]

      result = create_collection(data)
      expect(result.no_subject_or_all_subjects_or_graduates_remediation).to contain_exactly(result[0], result[1], result[2], result[4])
    end

    it "#all_subjects_or_subjects_in selects records with all subject or one in a list of specified subjects" do
      data = [
        hash.merge({"subject" => "Composite Subject"}),
        hash.merge({"subject" => "Any Subject"}),
        hash.merge({"subject" => "Math"}),
        hash.merge({"subject" => "English"}),
        hash.merge({"subject" => "Reading"})
      ]

      result = create_collection(data)
      expect(result.all_subjects_or_subjects_in(%w(Math Reading))).to contain_exactly(result[0], result[1], result[2], result[4])
    end

    it "#having_ethnicity_breakdown filters for records with an ethnicity breakdown_tag" do
      data = [
        hash.merge({"breakdown_tags" => "ethnicity", "breakdown" => "White"}),
        hash.merge({"breakdown_tags" => "ethnicity", "breakdown" => "African American"}),
        hash.merge({"breakdown_tags" => "gender", "breakdown" => "Male"}),
        hash.merge({"breakdown_tags" => "ethnicity", "breakdown" => "Asian"})
      ]

      result = create_collection(data)
      expect(result.having_ethnicity_breakdown).to contain_exactly(result[0], result[1], result[3])
    end

    it "#having_breakdown_in filters by an array of breakdowns" do
      data = [
        hash.merge({"breakdown" => "All students"}),
        hash.merge({"breakdown" => "White"}),
        hash.merge({"breakdown" => "African American"}),
        hash.merge({"breakdown" => "Asian"})
      ]

      result = create_collection(data)
      expect(result.having_breakdown_in(%w(Asian White))).to contain_exactly(result[1], result[3])
    end

    it "#having_all_students_or_breakdown_in should select records for all students or matching one of a list of breakdowns" do
      data = [
        hash.merge({"breakdown" => "All students"}),
        hash.merge({"breakdown" => "White"}),
        hash.merge({"breakdown" => "African American"}),
        hash.merge({"breakdown" => "Asian"}),
        hash.merge({"breakdown" => "Asian"})
      ]

      result = create_collection(data)
      expect(result.having_all_students_or_breakdown_in(%w(Asian))).to contain_exactly(result[0], result[3], result[4])
    end

    it "#recent_data_threshold filters collection to records greater or equal to a given year" do
      data = [
        hash.merge({"year" => "2017"}),
        hash.merge({"year" => "2016"}),
        hash.merge({"year" => "2017"}),
        hash.merge({"year" => "2015"})
      ]
      result = create_collection(data)
      expect(result.recent_data_threshold(2017)).to contain_exactly(result[0], result[2])
    end


    def create_collection(data)
      data.map {|d| MetricsCaching::Value.from_hash(d) }.extend(MetricsCaching::Value::CollectionMethods)
    end
  end

end