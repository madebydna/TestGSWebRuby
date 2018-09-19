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
    level_codes = st_and_lc_within_district.fetch(:level_codes, nil)
    if level_codes
      level_codes.map {|lc| lc.split(',')} # the level code for each record is a string, i.e. 'e,m,h' or 'e'. Need to count each instance
        .flatten
        .each_with_object(Hash.new(0)) {|lc, hash| hash[lc] += 1}
        .slice(*LevelCode::LEVEL_LOOKUP.keys)
    else
      LevelCode::LEVEL_LOOKUP.keys.each_with_object({}) {|lc, hash| hash[lc] = 0}
    end
  end

  def count_of_schools_by_type
    schools_by_type = st_and_lc_within_district.fetch(:types, nil)
    if schools_by_type
      schools_by_type
        .each_with_object(Hash.new(0)) {|type,hash| hash[type] += 1}
        .slice('public', 'charter')
    else
      {'public' => 0, 'charter' => 0}
    end
  end

end
