class DistrictRatingsCacher < DistrictCacher

  CACHE_KEY = 'ratings'

  @@test_data_types = Hash[TestDataType.all.map { |f| [f.id, f] }]


  cattr_accessor :test_data_types

  def test_data_types
    @@test_data_types
  end

  def query_results
    @query_results ||= (
    TestDataSet.ratings_for_district(district)
    )
  end

  def build_hash_for_cache
    hash = []
    query_results.each do |data_set_and_value|
      data_type_id = data_set_and_value.data_type_id
      if (test_data_types && test_data_types[data_type_id].present?)
        ratings_hash = build_ratings_cache(data_set_and_value)
        hash.push(ratings_hash)
      end
    end
    hash
  end

  def build_ratings_cache(data_set_and_value)
    {
        data_type_id: data_set_and_value.data_type_id,
        year: data_set_and_value.year,
        value_text: data_set_and_value.test_data_district_values[0].value_text,
        value_float: data_set_and_value.test_data_district_values[0].value_float,
        test_data_type_display_name:  test_data_types[data_set_and_value.data_type_id].display_name
    }
  end

  def self.listens_to?(data_type)
    :ratings == data_type
  end

end