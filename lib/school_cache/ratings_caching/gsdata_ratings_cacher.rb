class RatingsCaching::GsdataRatingsCacher < GsdataCaching::GsdataCacher
  CACHE_KEY = 'ratings'.freeze
  DATA_TYPE_IDS = [151,155,156,157,158,159,160,176].freeze

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
        # remove all data values except those with most recent date
        data_values.select! { |dv| dv.date_valid == most_recent_date }
        # select correct advanced coursework data values
        if data_type_id == 151
          data_values.select! do |dv|
            dv.breakdown_tags.blank? || dv.breakdown_tags == 'course_subject_group'
          end
        end
        accum.concat(data_values)
      end

      r.each_with_object(school_cache_hash) do |result, cache_hash|
        result_hash = result_to_hash(result)
        next unless validate_result_hash(result_hash, result.data_type_id)
        cache_hash[result.name] << result_hash
      end
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
      .having_no_breakdown
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
    if build_hash_for_cache.present?
      school_cache.update_attributes!(
          value: build_hash_for_cache.to_json,
          updated: Time.now
      )
    elsif school_cache && school_cache.id.present?
      SchoolCache.destroy(school_cache.id)
    end

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
