require 'spec_helper'

describe DistrictCacheResults do
  let(:ca_district) do
    instance_double(DistrictRecord, state: "ca", district_id: 1)
  end
  let(:mi_district) do
    instance_double(DistrictRecord, state: "mi", district_id: 1)
  end

  let(:query_results) do
    [
      OpenStruct.new(
        district_id: 1,
        state: "CA",
        name: "metrics",
        value: {}.to_json
      ),
      OpenStruct.new(
        district_id: 2,
        state: "CA",
        name: "ratings",
        value: {}.to_json
      ),
      OpenStruct.new(
        district_id: 1,
        state: "MI",
        name: "ratings",
        value: {}.to_json
      )
    ]
  end

  subject { DistrictCacheResults.new(%w(metrics district_school_summary), query_results) }

  describe "#data_hash" do
    let(:hash) { subject.data_hash }

    it "builds a by-state-and-district hash based on query results" do
      expect(hash).to include(["CA", 1], ["CA", 2], ["MI", 1])
    end

    it "builds a by-cache-key hash for each district" do
      expect(hash[["CA", 1]]).to include("metrics")
      expect(hash[["CA", 2]]).to include("ratings")
      expect(hash[["MI", 1]]).to include("ratings")
    end
  end

  describe "#decorate_districts" do
    let(:decorator) { decorator = double("DistrictCacheDecorator") }
    subject { DistrictCacheResults.new(%w(metrics ratings district_schools_summary), query_results) }

    it "should return DistrictCacheDecorator instances" do
      decorated_districts = subject.decorate_districts([ca_district, mi_district])
      expect(decorated_districts).to all ( be_a(DistrictCacheDecorator) )
    end

    it "should extend decorator with modules based on supplied cache keys" do
      decorator1 = double("DistrictCacheDecorator")
      decorator2 = double("DistrictCacheDecorator")
      expect(DistrictCacheDecorator).to receive(:new).
        with(ca_district, subject.data_hash[["CA", 1]]).and_return(decorator1)
      expect(decorator1).to receive(:extend).with(DistrictCachedMetricsMethods).ordered
      expect(decorator1).to receive(:extend).with(DistrictCachedRatingsMethods).ordered
      expect(decorator1).to receive(:extend).with(DistrictCachedDistrictSchoolsSummaryMethods).ordered

      expect(DistrictCacheDecorator).to receive(:new).
        with(mi_district, subject.data_hash[["MI", 1]]).and_return(decorator2)
      expect(decorator2).to receive(:extend).with(DistrictCachedMetricsMethods).ordered
      expect(decorator2).to receive(:extend).with(DistrictCachedRatingsMethods).ordered
      expect(decorator2).to receive(:extend).with(DistrictCachedDistrictSchoolsSummaryMethods).ordered

      subject.decorate_districts([ca_district, mi_district])
    end
  end

end