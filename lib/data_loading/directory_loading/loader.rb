# frozen_string_literal: true

class DirectoryLoading::Loader < Loader

  DATA_TYPE = :directory

  def load!
    updates.each do |update|
      next if update.blank?

      directory_update = DirectoryLoading::Update.new(data_type, update)

      entity = directory_update.entity

      begin
        if entity.is_a?(District)
          district = District.on_db(directory_update.shard).find(directory_update.entity_id)
          DistrictRecord.update_from_district(district, directory_update.shard)
        end
      rescue Exception => e
        raise e.message
      ensure
        Cacher.create_caches_for_data_type(entity, DATA_TYPE) if entity.is_a?(School)
      end
    end
  end
end
