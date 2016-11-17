require "spec_helper"

describe GsdataCaching::GsdataCacher do
  describe "#build_hash_for_cache" do
    it "should return correct hash" do
      school = build(:alameda_high_school)
      gsdb_cacher = GsdataCaching::GsdataCacher.new(school)

      expect(gsdb_cacher.build_hash_for_cache).to be_a(Hash)
      # expect(gsdb_cacher.build_hash_for_cache).to eq(result)
    end
  end
end
