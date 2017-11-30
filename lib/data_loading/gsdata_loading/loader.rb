class GsdataLoading::Loader < GsdataLoading::Base
  DATA_TYPE = :gsdata

  def load!
    updates.each do |update|
      next if update.blank?
      update = GsdataLoading::Update.new(update)

      school = School.on_db(update.state_db).find(update.school_id)

      if update.action == ACTION_BUILD_CACHE
        Cacher.create_caches_for_data_type(school, DATA_TYPE)
      end
    end
  end
end
