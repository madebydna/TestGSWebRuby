# frozen_string_literal: true

class DirectoryLoading::Loader < Loader

  DATA_TYPE = :directory

  def load!
    updates.each do |update|
      next if update.blank?

      directory_update = DirectoryLoading::Update.new(data_type, update)

      entity = directory_update.entity

      if entity.is_a?(District)
        district = District.on_db(directory_update.shard).find(directory_update.entity_id)
        DistrictRecord.update_from_district(district, directory_update.shard)
      elsif entity.is_a?(School)
        Cacher.create_caches_for_data_type(entity, DATA_TYPE)
      end

    end
  end
end
