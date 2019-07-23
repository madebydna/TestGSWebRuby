class RatingsCaching::GsdataRatingsCacher < GsdataCaching::GsdataCacher
  CACHE_KEY = 'ratings'.freeze

  # DATA_TYPES INCLUDED
  # 151: Advanced Coursework Rating
  # 155: Test Score Rating
  # 158: Equity rating
  # 159: Academic Progress Rating
  # 160: Summary Rating
  # 175: Summary Rating Weight: Advanced Course Rating
  # 176: Summary Rating Weight: Test Score Rating
  # 177: Summary Rating Weight: College Readiness Rating
  # 178: Summary Rating Weight: Student Progress Rating
  # 179: Summary Rating Weight: Equity Rating
  # 180: Summary Rating Weight: Academic Progress Rating
  # 181: Summary Rating Weight: Discipline Flag
  # 182: Summary Rating Weight: Absence Flag
  # 183: Discipline Flag
  # 184: Absence Flag
  # 185: Equity Adjustment Factor
  # 186: Summary Rating Weight: Equity Adjustment Factor
  # 187: CSA Badge






  DATA_TYPE_IDS = %w(151 155 156 157 158 159 160 175 176 177 178 179 180 181 182 183 184 185 186 187).freeze

  ADVANCED_COURSEWORK_DATA_TYPE_ID = 151
  CSA_AWARD_DATA_TYPE_ID = 187
  ALL_STUDENTS = 'All Students'
  COURSE_SUBJECT_GROUP = 'course_subject_group'
  BREAKDOWN_TAG_ETHNICITY = 'ethnicity'

  def self.listens_to?(data_type)
    :ratings == data_type
  end

  def build_hash_for_cache
    @_build_hash_for_cache ||= (
      school_cache_hash = Hash.new { |h, k| h[k] = [] }
      r = school_results

      # filter out some data values
      r = r.group_by(&:data_type_id).reduce([]) do |accum, (data_type_id, data_values)|
        most_recent_date = data_values.map(&:date_valid).max
        # remove all data values except those with most recent date except for CSA awards (data_type_id 187)
         if data_type_id != CSA_AWARD_DATA_TYPE_ID
          data_values.select! { |dv| dv.date_valid == most_recent_date }
         end
        # select correct advanced coursework data values
        if data_type_id == ADVANCED_COURSEWORK_DATA_TYPE_ID
          data_values.select! do |dv|
            advanced_coursework_select_logic?(dv)
          end
        end
        accum.concat(data_values)
      end

      r.each_with_object(school_cache_hash) do |result, cache_hash|
        result_hash = result_to_hash(result)
        result_hash[:description] = result.description if result.description    #source.description
        next unless validate_result_hash(result_hash, result.data_type_id)
        cache_hash[result.name] << result_hash
      end
    )
  end

  def school_results
    @_school_results ||=
      Rating.find_by_school_and_data_types_with_academics(school, data_type_ids)
  end

  def advanced_coursework_select_logic?(dv)
    breakdown_names = dv['breakdown_names'] || ''
    breakdown_tags = dv['breakdown_tags'] || ''
    breakdown_names_arr = breakdown_names.split(',')
    breakdown_tags_arr = breakdown_tags.split(',')
    academic_names_arr = (dv['academic_names'] || '').split(',')
    academic_tags_arr = (dv['academic_tags'] || '').split(',')
     (
      ( # this selects coursework for all students
          breakdown_names_arr.include?(ALL_STUDENTS) &&
          academic_tags_arr.include?(COURSE_SUBJECT_GROUP)
      ) ||
      ( # this selects all students overall data
          breakdown_names == ALL_STUDENTS &&
          breakdown_tags == 'all_students'
      ) ||
      ( # this is to select ethnicity data
          breakdown_names_arr.length == 1 &&
          breakdown_tags_arr.include?(BREAKDOWN_TAG_ETHNICITY) &&
          academic_names_arr.length.zero? &&
          academic_tags_arr.length.zero?
      )
     )
  end

  def test_score_only?
    data_value = school_results.find { |dv| dv.data_type_id == 176 }
    data_value.try(:value) == '1'
  end

  def gs_rating_data_value
    rating_object = test_score_only? ? build_hash_for_cache['Test Score Rating'] : build_hash_for_cache['Summary Rating']
    (rating_object || [])
      .map { |h| GsdataCaching::GsDataValue.from_hash(h) }
      .extend(GsdataCaching::GsDataValue::CollectionMethods)
      .for_all_students
      .having_school_value
      .expect_only_one('Should only find one summary rating', id: school.id, state: school.state)
  end

  def school_cache
    return @_school_cache if defined?(@_school_cache)
    @_school_cache = SchoolCache.find_or_initialize_by(
      school_id: school.id,
      state: school.state,
      name:self.class::CACHE_KEY
    )
  end

  def cache
    super

    if gs_rating_data_value.present?
      replace_rating_into_school_metadata(
        school.id,
        school.state.downcase,
        gs_rating_data_value.school_value
      )
    else
      delete_rating_row_from_school_metadata(school.id, school.state.downcase)
    end
  end

  def replace_rating_into_school_metadata(school_id, state, rating)
    table_name_prefix = "#{Rails.configuration.database_configuration["#{Rails.env}"][state]['database']}."
    retry_count = 0
    begin
      existing_row = SchoolMetadata.on_db("#{state}_rw").find_by(school_id: school_id, meta_key: 'overallRating')
      if existing_row
        SchoolMetadata.on_db("#{state}_rw") do
          query = "UPDATE #{table_name_prefix}school_metadata SET meta_value='#{rating.to_s}' WHERE school_id=#{school_id} AND meta_key='overallRating';"
          SchoolMetadata.connection.execute(query)
        end
      else
        SchoolMetadata.on_db("#{state}_rw").create(school_id: school_id, meta_key: 'overallRating', meta_value: rating.to_s)
      end
    rescue ActiveRecord::RecordNotUnique
      retry_count += 1
      retry if retry_count < 2
      GSLogger.error(:school_cache, nil, message: 'Endless loop inserting to school_metadata', vars: {school_id: school_id, state: state, rating: rating})
      raise
    end
  end

  def delete_rating_row_from_school_metadata(school_id, state)
    table_name_prefix = "#{Rails.configuration.database_configuration["#{Rails.env}"][state]['database']}."
    SchoolMetadata.on_db("#{state}_rw") do
      query = "delete from #{table_name_prefix}school_metadata where school_id = #{school_id} and meta_key='overallRating';"
      SchoolMetadata.connection.execute(query)
    end
  end
end
