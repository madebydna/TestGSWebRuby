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
    if current_ratings.present?
      json = (current_rating_hashes + historic_rating_hashes).to_json
      school_cache.update_attributes!(:value => json, :updated => Time.now)
    elsif school_cache && school_cache.id.present?
      SchoolCache.destroy(school_cache.id)
    end
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

  def current_rating_hashes
    current_ratings.map do |data_set|
      hash = data_set_to_hash(data_set)
      if data_set.data_type_id == 164 # test score rating
        hash[:description] = data_description_value('whats_this_test_scores')
        hash[:methodology] = data_description_value("footnote_test_scores#{school.state}")
      elsif data_set.data_type_id == 165 # growth rating
        hash[:description] = data_description_value('whats_this_growth')
        hash[:methodology] = data_description_value("footnote_growth#{school.state}")
      end
      hash
    end
  end

  def historic_rating_hashes
    historic_ratings.map { |data_set| data_set_to_hash(data_set) }
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
    id.present? && id > 0 ? self.class.test_data_breakdowns.seek(id, 'name') : nil
  end

  def data_description_value(key)
    dd = self.class.data_descriptions[key]
    dd.value if dd
  end
end
