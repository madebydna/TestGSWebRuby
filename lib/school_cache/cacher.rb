class Cacher

  attr_accessor :school

  # Known data types:
  # :ratings
  # :school_reviews
  # :school_media
  # :esp_response
  # :gsdata
  # :directory
  # :metrics
  # :feed_metrics
  # :test_scores_gsdata
  # :feed_test_scores_gsdata
  # :feed_old_test_scores_gsdata

  def initialize(school)
    @school = school
  end

  def write_cache_entry
    SchoolCache.on_rw_db do
      SchoolCache.connection.execute(
        %Q(
          INSERT INTO #{SchoolCache.table_name} (school_id, state, name, value, updated)
          VALUES (
            #{school.id},
            #{ActiveRecord::Base.connection.quote(school.shard_state)},
            #{ActiveRecord::Base.connection.quote(self.class::CACHE_KEY)},
            #{ActiveRecord::Base.connection.quote(build_hash_for_cache.to_json)},
            #{ActiveRecord::Base.connection.quote(Time.now)}
          )

          ON DUPLICATE KEY UPDATE
            value=#{ActiveRecord::Base.connection.quote(build_hash_for_cache.to_json)},
            updated=#{ActiveRecord::Base.connection.quote(Time.now)}
        )
      )
    end
  end

  def delete_cache_entry
    SchoolCache.on_rw_db do
      SchoolCache.delete_all(
        school_id: school.id,
        state: school.shard_state,
        name: self.class::CACHE_KEY
      )
    end
  end

  def cache
    if build_hash_for_cache.present?
      write_cache_entry
    else
      delete_cache_entry
    end
  end

  def active_record_to_hash(configuration_map, obj)
    rval_map = {}
    configuration_map.each do |key, val|
      if obj.attributes.include?(key.to_s)
        rval_map[val] = obj[key]
      elsif obj.respond_to?(key)
        rval_map[val] = obj.send(key)
      else
        Rails.logger.error "ERROR: Can't find attribute or method named #{key} in #{obj}"
      end
    end
    rval_map
  end

  def build_hash_for_cache
    raise NotImplementedError
  end

  # TODO: prune this list to only currently used cachers
  def self.cacher_for(key)
    {
        test_scores_gsdata:          TestScoresCaching::TestScoresCacherGsdata,
        metrics:                     MetricsCaching::SchoolMetricsCacher,
        esp_responses:               EspResponsesCaching::EspResponsesCacher,
        reviews_snapshot:            ReviewsCaching::ReviewsSnapshotCacher,
        gsdata:                      GsdataCaching::GsdataCacher,
        ratings:                     RatingsCaching::GsdataRatingsCacher,
        directory:                   DirectoryCaching::DirectoryCacher,
        feed_test_scores_gsdata:     TestScoresCaching::FeedTestScoresCacherGsdata,
        feed_old_test_scores_gsdata: TestScoresCaching::FeedOldTestScoresCacherGsdata,
        feed_metrics:                FeedMetricsCaching::SchoolFeedMetricsCacher
    }[key.to_s.to_sym]
  end

  # Should return true if param is a data type cacher depends on. See top of class for known data type symbols
  def self.listens_to?(_)
    raise NotImplementedError
  end

  def self.active?
    true
  end

  def self.cachers_for_data_type(data_type)
    data_type_sym = data_type.to_s.to_sym
    registered_cachers.select {|cacher| cacher.listens_to? data_type_sym }
  end

  def self.registered_cachers
    @registered_cachers ||= [
      TestScoresCaching::TestScoresCacherGsdata,
      MetricsCaching::SchoolMetricsCacher,
      EspResponsesCaching::EspResponsesCacher,
      ReviewsCaching::ReviewsSnapshotCacher,
      TestScoresCaching::FeedTestScoresCacherGsdata,
      TestScoresCaching::FeedOldTestScoresCacherGsdata,
      GsdataCaching::GsdataCacher,
      RatingsCaching::GsdataRatingsCacher,
      DirectoryCaching::DirectoryCacher,
      FeedMetricsCaching::SchoolFeedMetricsCacher
    ]
  end

  def self.create_caches_for_data_type(school, data_type)
    cachers_for_data_type(data_type).each do |cacher_class|
      begin
        cacher_class.new(school).cache if cacher_class.active?
      rescue => error
        error_vars = { data_type: data_type, school_state: school.state, school_id: school.id, shard: school.shard_state }
        GSLogger.error(:school_cache, error, vars: error_vars, message: 'Failed to build school cache')
      end
    end
  end

  def self.create_cache(school, cache_key)
    # begin
      cacher_class = cacher_for(cache_key)
      return unless cacher_class.active?
      cacher = cacher_class.new(school)
      cacher.cache
    # rescue => error
    #   error_vars = { cache_key: cache_key, school_state: school.state, school_id: school.id, shard: school.shard_state }
    #   GSLogger.error(:school_cache, error, vars: error_vars, message: 'Failed to build school cache')
    #   raise
    # end
  end

### BEGIN RATINGS CACHE CODE
# TODO move this out to its own classes structure

  def self.data_descriptions
    @_data_descriptions ||= Hash[DataDescription.all.map { |dd| [dd.data_key+dd.state.to_s, dd] }]
  end

  def self.test_data_breakdowns
    @_test_data_breakdowns = Hash[TestDataBreakdown.all.map { |f| [f.id, f] }]
  end

  def self.test_description_for(data_type_id,state)
    @@test_descriptions["#{data_type_id}#{state}"]
  end

### END RATINGS CACHE CODE

end

