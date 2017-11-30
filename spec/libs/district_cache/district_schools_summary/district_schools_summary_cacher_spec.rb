require "spec_helper"

describe DistrictSchoolsSummary::DistrictSchoolsSummaryCacher do
  after do
    clean_dbs(:ca)
  end
  describe '#build_hash_for_cache' do
    it "should return hash that contains school counts by level code" do
      district = build(:alameda_city_unified)
      schools_summary_cacher = DistrictSchoolsSummary::DistrictSchoolsSummaryCacher.new(district)
      allow(schools_summary_cacher)
        .to receive(:schools_count_by_level_code)
        .and_return(schools_count_by_level)
      level_code_key = "school counts by level code"

      expect(schools_summary_cacher.build_hash_for_cache).to be_a(Hash)
      expect(schools_summary_cacher.build_hash_for_cache)
        .to have_key(level_code_key)
      expect(schools_summary_cacher.build_hash_for_cache[level_code_key])
        .to eq(schools_count_by_level)
    end
  end

  describe "#schools_count_by_level_code" do
    it "should return hash with count of schools by level" do
      district = create(:alameda_city_unified)
      create_district_schools_for_district(district)

      schools_summary_cacher = DistrictSchoolsSummary::DistrictSchoolsSummaryCacher.new(district)
      result = schools_count_by_level

      expect(schools_summary_cacher.send(:schools_count_by_level_code))
        .to be_a(Hash)
      expect(schools_summary_cacher.send(:schools_count_by_level_code))
        .to eq(result)
    end
  end

  def create_district_schools_for_district(district)
    district_id = district.id
    # elementary only
    create(:school, level_code: "e", district_id: district_id)
    # elementary_and_middle
    create(:school, level_code: "e,m", district_id: district_id)
    # middle_only
    create(:school, level_code: "m", district_id: district_id)
    # middle_and_high
    create(:school, level_code: "m,h", district_id: district_id)
    # high_only
    create(:school, level_code: "h", district_id: district_id)
  end

  def schools_count_by_level
    {
      e: 2,
      m: 3,
      h: 2
    }
  end
end
