# frozen_string_literal: true

class DirectoryLoading::Loader < Loader

  DATA_TYPE = :directory

  def load!
    updates.each do |update|
      next if update.blank?

      directory_update = DirectoryLoading::Update.new(data_type, update)

      entity = directory_update.entity

      begin
        # Space reserved for future implementations
      ensure
        Cacher.create_caches_for_data_type(entity, DATA_TYPE) if entity.is_a?(School)
        DistrictCacher.create_caches_for_data_type(entity, DATA_TYPE) if entity.is_a?(District)
      end
    end
  end
end
