class SchoolLocationLoading::Loader < SchoolLocationLoading::Base

  CACHE_KEY = 'nearby_schools'
  DATA_TYPE = :school_location

  def load!
    updates.each do |update|
      next if update.blank?

      sl_update = SchoolLocationLoading::Update.new(data_type, update)

      school = School.on_db(sl_update.entity_state.to_s.downcase.to_sym).find(sl_update.entity_id)

      begin
        if sl_update.action == ACTION_BUILD_CACHE
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