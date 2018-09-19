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
      SCHOOLS_COUNTS_BY_TYPE => count_of_schools_by_type
    }
  end

  private

  def st_and_lc_within_district
    @_school_types_and_level_codes_within_district ||= begin
      types_and_level_codes = School.on_db(district.shard){School.active.where(district_id: district.id).pluck(:type,:level_code)}.transpose
      {
        :types => types_and_level_codes.first,
        :level_codes => types_and_level_codes.last
      }
    end
  end

  def count_of_schools_by_level_code
    st_and_lc_within_district
      .fetch(:level_codes, []).map {|lc| lc.split(',')}  # the level code for each record is a string, i.e. 'e,m,h'
      .flatten # after splitting, the array may contain a mix of strings and arrays
      .each_with_object(Hash.new(0)) {|lc, hash| hash[lc] += 1}
      .slice(*LevelCode::LEVEL_LOOKUP.keys)
  end

  def count_of_schools_by_type
    st_and_lc_within_district
      .fetch(:types, [])
      .each_with_object(Hash.new(0)) {|type,hash| hash[type] += 1}
      .slice('public', 'charter')
  end

end
