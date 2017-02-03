# cacher to cache summary data for a district's schools
# writes out district schools summary value for district cache:
# {
# "school counts by level code" => {
#  {
#    e: 2,
#    m: 3,
#    h: 2
#   }
# }
class DistrictSchoolsSummary::DistrictSchoolsSummaryCacher < DistrictCacher
  CACHE_KEY = "district_schools_summary".freeze
  SCHOOLS_COUNTS_BY_LEVEL_CODE_KEY = "school counts by level code".freeze

  def build_hash_for_cache
    {
      SCHOOLS_COUNTS_BY_LEVEL_CODE_KEY => schools_count_by_level_code
    }
  end

  private

  def schools_count_by_level_code
    count_of_schools_at_each_level(count_of_schools_for_each_level_code)
  end

  def count_of_schools_for_each_level_code
    district.on_db(district.state.downcase.to_sym)
      .schools
      .group("level_code").count
  end

  def count_of_schools_at_each_level(count_of_level_code_set_values)
    count_of_level_code_set_values
      .each_with_object(Hash.new(0)) do |(level_code_set, count), h|
      level_code_set.split(",").each do |level_code|
        h[level_code.to_sym] += count
      end
    end
  end
end
