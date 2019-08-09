require 'spec_helper'

describe StateCacheResults do
  let(:results) {
    [
      OpenStruct.new(
        state: "ca",
        name: "school_levels",
        value: { "elementary": [{ state_value: 100 }] }.to_json
      )
    ]
  }

  subject { StateCacheResults.new("school_levels", results) }

  describe '#decorate_state' do
    let(:expected_state_data) do
      {
        "school_levels" => {
          "elementary" => [{ "state_value" => 100 }]
        }
      }
    end

    it "should return a StateCacheDecorator" do
      expect(subject.decorate_state("ca")).to be_a(StateCacheDecorator)
    end

    it "should instantiate the StateCacheDecorator with the state name and data" do
      expect(StateCacheDecorator).to receive(:new).with('ca', expected_state_data)
      subject.decorate_state("ca")
    end

    it "should extend the StateCacheDecorator with methods based on cache keys" do
      expect(subject.decorate_state("ca")).to respond_to(:school_levels)
    end

  end
end