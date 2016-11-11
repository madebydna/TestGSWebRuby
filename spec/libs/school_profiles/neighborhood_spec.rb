require "spec_helper"

describe SchoolProfiles::Neighborhood do
  describe "#school_address_css_class" do
    context "with street name character length greater than 50" do
      it "should return small-text css class" do
        cache_data_reader = double(gs_rating: "5")
        street_address_50_chars = "12345678910" * 5
        school = build(:school, street: street_address_50_chars)
        expect(SchoolProfiles::Neighborhood.new(school, cache_data_reader)
          .school_address_css_class).to eq(" small-text")
      end
    end
    context "with street name character length less than 50" do
      it "should return empty string" do
        street_address = "123 main st"
        cache_data_reader = double(gs_rating: "5")
        school = build(:school, street: street_address)
        expect(SchoolProfiles::Neighborhood.new(school, cache_data_reader)
          .school_address_css_class).to eq("")
      end
    end
  end

  describe "static_google_maps" do
    it "should return a hash of google map urls" do
      school = build(:school)
      cache_data_reader = double(gs_rating: "5")
      expect(SchoolProfiles::Neighborhood.new(school, cache_data_reader)
        .static_google_maps).to be_a(Hash)
      expect(SchoolProfiles::Neighborhood.new(school, cache_data_reader)
        .static_google_maps.keys).to eq(%w(sm md lg))
    end
  end
end
