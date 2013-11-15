require 'table_data'
require 'hash_utils'

class CategoryDataReader
  include SchoolCategoryDataCacher

  def self.esp_response(school, category)
    esp_responses = EspResponse.on_db(school.shard).where(school_id: school.id).where(active: 1)

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

  def self.dummy(school, _)
    return {dummy:true}
  end

  def self.details(school, category)
    data_details = esp_data_points(school, category);

    details_response_keys = {
        art: ['arts_media', 'arts_music', 'arts_performing_written', 'arts_visual'],
        sport: ['girls_sports', 'boys_sports'],
        club: ['student_clubs'],
        lang: ['foreign_language']
    }
    return_counts_details = {
        art: "-",
        sport:"-",
        club: "-",
        lang: "-"
    }

    # loop through details and handle total count for 0, infinity cases
    #  zero is a dash -
    #  check if value for all is none
    #  don't add none to count
    details_response_keys.keys.each do |osp_key|
       return_counts_details[osp_key] = details_response_keys[osp_key].sum do | key |
          (Array(data_details[key]).count{|item| item != "none"})
        end
      if return_counts_details[osp_key] == 0
        none_count = details_response_keys[osp_key].sum do | key |
          (Array(data_details[key]).count{|item| item == "none"})
        end
        return_counts_details[osp_key] = none_count == 0 ?  "-" : 0
      end
    end
    return_counts_details
  end



  def self.esp_data_points(school, _)
    data = EspResponse.on_db(school.shard).where(school_id: school.id)

    unless data.nil?
      # since esp_response has multiple rows with the same key, roll up all values for a key into an array
      responses_per_key = data.group_by(&:response_key)
      responses_per_key.values.each { |values| values.map!(&:response_value) }
    end

    #Merge start_time and end_time into hours.
    HashUtils.merge_keys responses_per_key, 'start_time', 'end_time', 'hours' do |value1 ,value2|
      value1.first.to_s + '-' + value2.first.to_s
    end

    #Split before_after_care into before_care and after_care.
    HashUtils.split_keys responses_per_key, 'before_after_care' do |value|
      result_hash = {}
      if value.kind_of?(Array)
        value.each do |val|
          result_hash[val.downcase  + "_care"] =  val.downcase  unless val.nil?
        end
      end
      result_hash
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
  {"district" => school.district.name, "type" => school.subtype}
  end

  def self.snapshot(school, category)

    snapshot_results = []

    key_source = {
        enrollment: 'census_data_points',
        hours: 'esp_data_points',
        :"head official name" => 'census_data_points',
        transportation: 'esp_data_points',
        :"students per teacher" => 'census_data_points',
        capacity: 'census_data_points',
        before_care: 'esp_data_points',
        after_care: 'esp_data_points',
        district: 'school_data',
        type: 'school_data'
    }

    key_filters = {enrollment: {level_codes: ['p', 'e', 'm', 'h'], school_types: ['public', 'charter', 'private']},
                   hours: {level_codes: ['p', 'e', 'm', 'h'], school_types: ['public', 'charter', 'private']},
                   :"head official name" => {level_codes: ['p', 'e', 'm', 'h'], school_types: ['public', 'charter', 'private']},
                   transportation: {level_codes: ['p', 'e', 'm', 'h'], school_types: ['public', 'charter', 'private']},
                   :"students per teacher" => {level_codes: ['p'], school_types: ['public', 'charter', 'private']},
                   capacity: {level_codes: ['p'], school_types: ['public', 'charter', 'private']},
                   before_care: {level_codes: ['e', 'm'], school_types: ['public', 'charter', 'private']},
                   after_care: {level_codes: ['e', 'm'], school_types: ['public', 'charter', 'private']},
                   district: {level_codes: ['p', 'e', 'm', 'h'], school_types: ['public', 'charter']},
                   type: {level_codes: ['p', 'e', 'm', 'h'], school_types: ['private']}
    }

    all_snapshot_keys = category.category_data(school.collections).map(&:response_key)

    #Get the labels for the response keys from the ResponseValue table.
    lookup_table_for_labels = ResponseValue.lookup_table(category)

    all_snapshot_keys.each do  |key|

      #Filter out the keys based on level codes and school type
      if (key_filters[key.to_sym][:level_codes].include? school.level_code) && (key_filters[key.to_sym][:school_types].include? school.type)

        #get the source for the response key
        source = key_source[key.to_sym]
        if source.present?

          #Get the data. data_for_source is a map with a key.
          data_for_source = self.send(source.to_sym, school, category)
          if data_for_source.present? && data_for_source.any?

            #esp_data returns an array and census does not return an array. Therefore cast everything to an array and read
            #the first value.
            value = Array(data_for_source[key]).first
            #Get the labels for the response keys from the ResponseValue table.
            key = lookup_table_for_labels[key] || key

            if value.present?
                snapshot_results << {key => value}
            else
              snapshot_results << {key => "n/a"}
            end

          end
        end
      end

    end
    snapshot_results
  end

  cache_methods :student_ethnicity, :test_scores, :enrollment, :esp_response
end
