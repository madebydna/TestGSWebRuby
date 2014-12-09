class SchoolMediaLoading::Loader < SchoolMediaLoading::Base

  CACHE_KEY = 'progress_bar'
  DATA_TYPE = :school_media

  def load!
    updates.each do |update|
      next if update.blank?

      school_media_update = SchoolMediaLoading::Update.new(data_type, update)

      school = School.on_db(school_media_update.entity_state.to_s.downcase.to_sym).find(school_media_update.entity_id)

      begin
        if school_media_update.action == ACTION_BUILD_CACHE
          # do nothing
        end
      rescue Exception => e
        raise e.message
      ensure
        Cacher.create_caches_for_data_type(school, DATA_TYPE)
      end
    end
  end
end