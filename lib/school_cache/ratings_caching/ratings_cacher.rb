class RatingsCaching::RatingsCacher < Cacher
  CACHE_KEY = 'ratings'

  def self.listens_to?(data_type)
    :ratings == data_type
  end

  def cache
    school_cache = SchoolCache.find_or_initialize_by(
      school_id: school.id,
      state: school.state,
      name: 'ratings'
    )
    school_overall_rating = nil
    if current_ratings.present?
      json = current_rating_hashes.to_json
      school_cache.update_attributes!(:value => json, :updated => Time.now)
      current_ratings.each do |h|
        school_overall_rating = h.school_value_float.to_i if (
          h.data_type_id == 174 &&
          h.subject_id == 1 &&
          h.breakdown_id == 1 &&
          h.school_value_float.present?
        )
      end
      if school_overall_rating.present?
        replace_rating_into_school_metadata(school.id, school.state.downcase, school_overall_rating)
      else
        delete_rating_row_from_school_metadata(school.id, school.state.downcase)
      end
    else
      delete_rating_row_from_school_metadata(school.id, school.state.downcase)
      SchoolCache.destroy(school_cache.id) if (school_cache && school_cache.id.present?)
    end
  end

  def replace_rating_into_school_metadata(school_id, state, rating)
    retry_count = 0
    begin
      existing_row = SchoolMetadata.on_db("#{state}_rw").find_by(school_id: school_id, meta_key: 'overallRating')
      if existing_row
        SchoolMetadata.on_db("#{state}_rw") do
          query = "UPDATE #{table_name_prefix(state)}school_metadata SET meta_value='#{rating.to_s}' WHERE school_id=#{school_id} AND meta_key='overallRating';"
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
    SchoolMetadata.on_db("#{state}_rw") do
      query = "delete from #{table_name_prefix(state)}school_metadata where school_id = #{school_id} and meta_key='overallRating';"
      SchoolMetadata.connection.execute(query)
    end
  end

  def table_name_prefix(state)
    "#{Rails.configuration.database_configuration["#{Rails.env}"][state]['database']}."
  end

  def current_ratings
    @_current_ratings = (
      TestDataSet.ratings_for_school(school).reject do |data_set|
        # Prune out empty data sets
        data_set.school_value_text.nil? && data_set.school_value_float.nil?
      end
    )
  end

  def historic_ratings
    @_historic_ratings = 
      TestDataSet.historic_ratings_for_school(
        school,
        current_ratings.map(&:data_type_id),
        current_ratings.map(&:id)
      ).reject do |data_set|
        # Prune out empty data sets
        data_set.school_value_text.nil? && data_set.school_value_float.nil?
      end
  end

  def current_rating_data_types
    current_rating_hashes.select { |h| h['breakdown'] == 'All students'}.map { |h| h['data_type_id'] }
  end

  def relevant_historical_rating_hashes
    current_rating_data_types.map do |data_type_id|
      historic_rating_hashes.select { |h| h['data_type_id'] == data_type_id }
    end
  end

  def current_rating_hashes
    @_current_rating_hashes ||= (current_ratings.map do |data_set|
      hash = data_set_to_hash(data_set)
      if data_set.data_type_id == 164 # test score rating
        hash[:description] = data_description_value('whats_this_test_scores')
        hash[:methodology] = data_description_value("footnote_test_scores#{school.state}")
      elsif data_set.data_type_id == 165 # growth rating
        hash[:description] = data_description_value('whats_this_growth')
        hash[:methodology] = data_description_value("footnote_growth#{school.state}")
      elsif data_set.data_type_id == 166 # college readiness rating
        hash[:description] = data_description_value('whats_this_psr')
        hash[:methodology] = data_description_value("footnote_psr#{school.state}")
      end
      hash
    end)
  end

  def historic_rating_hashes
    @_historic_rating_hashes ||= (historic_ratings.map { |data_set| data_set_to_hash(data_set) })
  end

  def data_set_to_hash(data_set)
    {
      'data_type_id' => data_set.data_type_id,
      'year' => data_set.year,
      'school_value_text' => data_set.school_value_text,
      'school_value_float' => data_set.school_value_float,
      'level_code' => data_set.level_code,
      'test_data_type_display_name' => data_set.test_data_type.try(:display_name),
      'breakdown' => breakdown_name(data_set.breakdown_id)
    }.reject { |key, value| key == 'breakdown' && value.nil? }
  end

  def breakdown_name(id)
    if id.present? && id > 0
      breakdown = self.class.test_data_breakdowns[id]
      breakdown.name if breakdown
    end
  end

  def data_description_value(key)
    dd = self.class.data_descriptions[key]
    dd.value if dd
  end
end
