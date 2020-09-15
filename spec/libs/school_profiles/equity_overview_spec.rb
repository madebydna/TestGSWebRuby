require 'spec_helper'

describe SchoolProfiles::EquityOverview do
  describe '#overview_data' do
    let(:equity_overview_data) do
      {
        "Equity Rating: State Test Percentile" =>[
          OpenStruct.new(breakdowns:["Disadvantaged Students"],
            school_value: "0.43340123210475673",
            source_date_valid: "2020-07-29T19:47:00-07:00",
            source_name: "GreatSchools"),
          OpenStruct.new(breakdowns:["Advantaged Students"],
            school_value: "0.89396370475673",
            source_date_valid: "2020-07-29T19:47:00-07:00",
            source_name: "GreatSchools")
        ],
        "Equity Rating: Growth Proxy Percentile" => [
          OpenStruct.new(breakdowns:["Disadvantaged Students"],
            school_value: "0.44572072072072066",
            source_date_valid: "2020-07-29T19:47:00-07:00",
            source_name: "GreatSchools"),
          OpenStruct.new(breakdowns:["Advantaged Students"],
            school_value: "0.738038038038038",
            source_date_valid: "2020-07-29T19:47:00-07:00",
            source_name: "GreatSchools")
        ],
        "Equity Rating: College Readiness Percentile" => [
          OpenStruct.new(breakdowns:["Disadvantaged Students"],
            school_value: "0.4340955567949433",
            source_date_valid: "2020-07-29T19:47:00-07:00",
            source_name: "GreatSchools"),
          OpenStruct.new(breakdowns:["Advantaged Students"],
            school_value: "0.5762688232013385",
            source_date_valid: "2020-07-29T19:47:00-07:00",
            source_name: "GreatSchools")
        ]
      }
    end
    let(:school_cache_data_reader) do
      double(
        equity_overview_data: equity_overview_data,
        growth_type: "Academic Progress Rating"
      )
    end
    subject { SchoolProfiles::EquityOverview.new(school_cache_data_reader: school_cache_data_reader, equity: double("Equity")) }

    let(:expected_keys) { ["Academic Progress", "College Readiness", "Test Scores"] }

    it "should present expected data types" do
      expect(subject.overview_data).to include(*expected_keys)
    end

    it "should have advantaged and disadvataged breakdowns for each data type" do
      result = subject.overview_data
      expected_keys.each do |key|
        expect(result[key]).to include("Disadvantaged Students", "Advantaged Students")
      end
    end

    it "should use school value as rounded percentage for both breakdowns" do
      result = subject.overview_data
      expect(result["Academic Progress"]["Disadvantaged Students"]).to eq("45%")
      expect(result["Academic Progress"]["Advantaged Students"]).to eq("74%")
      expect(result["College Readiness"]["Disadvantaged Students"]).to eq("43%")
      expect(result["College Readiness"]["Advantaged Students"]).to eq("58%")
      expect(result["Test Scores"]["Disadvantaged Students"]).to eq("43%")
      expect(result["Test Scores"]["Advantaged Students"]).to eq("89%")
    end

    context "with only one breakdown for a data type" do
      let(:equity_overview_data_missing_breakdown) do
        equity_overview_data["Equity Rating: State Test Percentile"].delete_at(0)
        equity_overview_data
      end

      let(:school_cache_data_reader) do
        double(
          equity_overview_data: equity_overview_data_missing_breakdown,
          growth_type: "Academic Progress Rating"
        )
      end

      it "should exclude that data type" do
        expect(subject.overview_data).not_to include("Test Scores")
      end
    end

    context "for 'Student Progress' state" do
      let(:equity_overview_data_student_progress) do
        equity_overview_data["Equity Rating: Growth Percentile"] = equity_overview_data.delete("Equity Rating: Growth Proxy Percentile")
        equity_overview_data
      end

      let(:school_cache_data_reader) do
        double(
          equity_overview_data: equity_overview_data_student_progress,
          growth_type: "Student Progress Rating"
        )
      end

      it "should have key for Student Progress" do
        expect(subject.overview_data).to include("Student Progress")
        expect(subject.overview_data).not_to include("Academic Progress")
      end
    end
  end
end