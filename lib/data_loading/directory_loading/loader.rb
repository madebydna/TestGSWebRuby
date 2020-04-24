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
        school = School.on_db(directory_update.shard).find(directory_update.entity_id)

        if school.active
          SchoolRecord.update_from_school(school, directory_update.shard)
        else
          SchoolRecord.find_by_unique_id("#{directory_update.shard}-#{school.id}")&.destroy
        end
        # Used to build the cache for directory feeds. May not be needed anymore
        # leaving it in for now
        Cacher.create_caches_for_data_type(entity, DATA_TYPE)
      end

    end
  end
end
