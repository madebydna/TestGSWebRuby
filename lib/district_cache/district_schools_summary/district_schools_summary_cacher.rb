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

  def column_data_for_schools_within_district(column)
    @_schools_within_district ||= begin
      School.on_db(district.shard) { School.active.where(district_id: district.id).pluck(column) }
    end
  end

  def count_of_schools_by_level_code
    level_code_counts = LevelCode::LEVEL_LOOKUP.keys.each_with_object({}) {|lc, hash| hash[lc] = 0}
    column_data_for_schools_within_district(:level_code).each do |level_codes|
      split_lc = level_codes.split(',')
      split_lc.each do |lc|
        # Don't increment counter if level code is not included in LevelCode::LEVEL_LOOKUP.keys
        cleaned_lc = lc.strip.downcase
        level_code_counts[cleaned_lc] += 1 if level_code_counts.has_key?(cleaned_lc)
      end
    end

    level_code_counts
  end

  def count_of_schools_by_type
    school_type_counts = {'public' => 0, 'charter' => 0}
    column_data_for_schools_within_district(:type).each do |st|
      # Don't increment counter if school type is not 'public' or 'charter'
      cleaned_st = st.strip.downcase
      school_type_counts[cleaned_st] += 1 if school_type_counts.has_key?(cleaned_st)
    end

    school_type_counts
  end

end
