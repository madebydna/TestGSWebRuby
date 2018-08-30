# cacher to cache summary data for a district's schools
# writes out district schools summary value for district cache:
# {
#   "school counts by level code": {
#     "p": 0,
#     "e": 12,
#     "m": 9,
#     "h": 7
#   },
#   "school counts by type": {
#     "public": 17,
#     "charter": 5
#   }
# }
class DistrictSchoolsSummary::DistrictSchoolsSummaryCacher < DistrictCacher
  CACHE_KEY = "district_schools_summary".freeze
  SCHOOLS_COUNTS_BY_LEVEL_CODE_KEY = "school counts by level code".freeze
  SCHOOLS_COUNTS_BY_TYPE = "school counts by type".freeze

  def build_hash_for_cache
    {
      SCHOOLS_COUNTS_BY_LEVEL_CODE_KEY => count_of_schools_by_level_code,
      SCHOOLS_COUNTS_BY_TYPE => count_of_schools_by_type,
    }
  end

  private

  def schools_within_district
    @_schools_within_district ||= School.within_district(district)
  end

  def count_of_schools_by_level_code
    level_code_counts = LevelCode::LEVEL_LOOKUP.keys.each_with_object({}) {|lc, hash| hash[lc] = 0}
    schools_within_district.pluck('level_code').each do |level_codes|
      split_lc = level_codes.split(',')
      split_lc.each {|lc| level_code_counts[lc.strip.downcase] += 1}
    end
    level_code_counts
  end

  def count_of_schools_by_type
    school_type_counts = {'public' => 0, 'charter' => 0}
    schools_within_district.pluck('type').each {|st| school_type_counts[st.strip.downcase] += 1}
    school_type_counts
  end

end
