require 'table_data'

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

  def self.details(school, category)
    esp_responses = EspResponse.on_db(school.shard).where(school_id: school.id && active=1)

    keys_to_use = category.category_data(school.collections).map(&:response_key)

    # We grabbed all the school's data, so we need to filter out rows that dont have the keys that we need
    data = esp_responses.select! { |response| keys_to_use.include? response.response_key }
  end

  def self.esp_data_points(school, _)
    data = EspResponse.on_db(school.shard).where(school_id: school.id)

    unless data.nil?
      # since esp_response has multiple rows with the same key, roll up all values for a key into an array
      responses_per_key = data.group_by(&:response_key)
      responses_per_key.values.each { |values| values.map!(&:response_value) }
    end

    responses_per_key
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

  def self.census_data_points(school, _)
    results = CensusDataForSchoolQuery.new(school)
    .data_for_school
    .filter_to_max_year_per_data_type!(school.state)

    results ||= []

    results_hash = {}

    results.each do |census_data_set|
      if census_data_set.school_value
        results_hash[census_data_set.data_type.downcase] = census_data_set.school_value
      end
    end

    results_hash
  end

  def self.student_ethnicity(school, _)

    results = CensusDataForSchoolQuery.new(school)
      .data_for_school
      .filter_to_max_year_per_data_type!(school.state)
      .for_data_type!('ethnicity')

    results ||= []

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
    else
      nil
    end
  end

  def self.test_scores(school, _)
    school.test_scores
  end

  def self.school_data(school, _)
  {"district" => school.district_id, "type" => school.subtype}
  end

  def self.snapshot(school, category)

    snapshot_results = {}

    key_source = {
        enrollment: 'census_data_points',
        start_time: 'esp_data_points',
        end_time: 'esp_data_points',
        :"head official name" => 'census_data_points',
        transportation: 'esp_data_points',
        :"students per teacher" => 'census_data_points',
        capacity: 'census_data_points',
        before_after_care: 'esp_data_points',
        district: 'school_data',
        type: 'school_data'
    }

    key_filters = { enrollment: {level_codes: ['p','e','m','h'], school_types: ['public','charter','private'] },
                    start_time: {level_codes: ['p','e','m','h'], school_types: ['public','charter','private'] },
                    end_time: {level_codes: ['p','e','m','h'], school_types: ['public','charter','private'] },
                    :"head official name" => {level_codes: ['p','e','m','h'], school_types: ['public','charter','private'] },
                    transportation: {level_codes: ['p','e','m','h'], school_types: ['public','charter','private'] },
                    :"students per teacher" => {level_codes: ['p'], school_types: ['public','charter','private'] },
                    capacity: {level_codes: ['p'], school_types: ['public','charter','private'] },
                    before_after_care: {level_codes: ['e','m'], school_types: ['public','charter','private'] },
                    district: {level_codes: ['p','e','m','h'], school_types: ['public','charter'] },
                    type: {level_codes: ['p','e','m','h'], school_types: ['private']}
    }

    all_snapshot_keys = category.category_data(school.collections).map(&:response_key)

    all_snapshot_keys.each do  |key|

      if (key_filters[key.to_sym][:level_codes].include? school.level_code) && (key_filters[key.to_sym][:school_types].include? school.type)

        source = key_source[key.to_sym]

        if source.present?
          data_for_source = self.send(source.to_sym ,school,category)
          if data_for_source.present? && data_for_source.any?
            value =  data_for_source[key]
            if value.present?
              snapshot_results[key] = value
            end
          end
        end
      end

      #TODO special keys, district name, key names, comments

    end
    snapshot_results
  end

  cache_methods :student_ethnicity, :test_scores, :enrollment, :esp_response

end
