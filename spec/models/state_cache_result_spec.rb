require 'spec_helper'

describe StateCacheResults do
  let(:results) {
    [
      OpenStruct.new(
        state: "ca",
        name: "school_levels",
        value: { "elementary": [{ state_value: 100 }] }.to_json
      ),
      OpenStruct.new(
        state: "ca",
        name: "metrics",
        value: {
          "Ethnicity" => [
            {
              "breakdown" => "Native American",
              "grade" => "All",
              "source" => "California Department of Education",
              "state_value" => 0.506499,
              "subject" => "Not Applicable",
              "year" => 2019
            },
            {
              "breakdown" => "Filipino",
              "grade" => "All",
              "source" => "California Department of Education",
              "state_value" => 2.420830,
              "subject" => "Not Applicable",
              "year" => 2019
            }
          ]
        }.to_json
      )
    ]
  }

  subject { StateCacheResults.new(["school_levels", "metrics"], results) }

  describe '#decorate_state' do
    let(:expected_state_data) do
      {
        "school_levels" => JSON.parse(results.first.value),
        "metrics" => JSON.parse(results.last.value)
      }
    end

    it "should return a StateCacheDecorator" do
      expect(subject.decorate_state("ca")).to be_a(StateCacheDecorator)
    end

    it "should instantiate the StateCacheDecorator with the state name and data" do
      expect(StateCacheDecorator).to receive(:new).with('ca', expected_state_data)
      subject.decorate_state("ca")
    end

    describe "should extend the StateCacheDecorator instance with modules based on cache keys" do
      let(:decorated) { subject.decorate_state("ca") }
      it "e.g. school_levels => StateCachedSchoolLevelsMethods" do
        expect(decorated).to respond_to(:school_levels)
      end

      it "e.g. metrics => StateCachedMetricsMethods" do
        expect(decorated).to respond_to(:metrics)
        expect(decorated).to respond_to(:ethnicity_data)
        expect(decorated).to respond_to(:with_all_students)
        expect(decorated).to respond_to(:with_state_value)
      end
    end
  end
end