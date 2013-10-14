class CategoryDataReader
  include SchoolCategoryDataCacher

  def self.esp_response(school, category)
    esp_responses = EspResponse.on_db(school.shard).where(school_id: school.id)

    keys_to_use = category.category_data(school.collections).map(&:response_key)

    # We grabbed all the school's data, so we need to filter out rows that dont have the keys that we need
    data = esp_responses.select! { |response| keys_to_use.include? response.response_key}

    unless data.nil?
      # since esp_response has multiple rows with the same key, roll up all values for a key into an array
      responses_per_key = data.group_by(&:response_key)
      responses_per_key.values.each { |values| values.map!(&:response_value) }

      table_data = TableData.from_hash responses_per_key, :label, :value

      lookup_table = ResponseValue.lookup_table(school.collections)
      table_data.transform_column! :label, lookup_table
      table_data.transform_column! :value, lookup_table
      table_data
    end
  end

  def self.enrollment(school, _)

    results = CensusDataForSchoolQuery.new(school)
    .data_for_school
    .filter_to_max_year_per_data_type!(school.state)
    .for_data_type!('enrollment')

    if results && results.any?
      results.first.school_value
    end

  end

  def self.student_ethnicity(school, _)

    results = CensusDataForSchoolQuery.new(school)
      .data_for_school
      .filter_to_max_year_per_data_type!(school.state)
      .for_data_type!('ethnicity')

    rows = results.map do |census_data_set|
      if census_data_set.state_value && census_data_set.school_value
        {
            ethnicity: census_data_set.census_breakdown,
            school_value: census_data_set.school_value.round,
            state_value: census_data_set.state_value.round
        }
      end
    end.compact

    rows.sort_by! { |row| row[:school_value] }.reverse!

    if rows.any?
      TableData.new rows
    end
  end

  def self.test_scores(school, _)
    school.test_scores
  end

  #cache_methods :student_ethnicity, :test_scores

end
