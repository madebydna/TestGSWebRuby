# frozen_string_literal: true

class DirectoryLoading::Loader < Loader

  DATA_TYPE = :directory

  def load!
    updates.each do |update|
      next if update.blank?

      directory_update = DirectoryLoading::Update.new(data_type, update)

      # Raises entity not found exception if one doesn't exist with that ID
      entity = directory_update.entity

      begin
        # We only support cache builds at this time
      rescue Exception => e
        raise e.message
      ensure
        Cacher.create_caches_for_data_type(entity, DATA_TYPE) if entity.is_a?(School)
        DistrictCacher.create_caches_for_data_type(entity, DATA_TYPE) if entity.is_a?(District)
      end
    end
  end
end
