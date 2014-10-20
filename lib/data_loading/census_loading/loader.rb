class CensusLoading::Loader < CensusLoading::Base

  # TODO handle census_description, census_data_set_file
  # Best ordering: first create data sets, then gs_schooldb.census_* rows, then value row
  # TODO break out data set code into module

  def load!
    puts self.class

    census_data_type = census_data_types[data_type]

    updates.each do |update|
      next if update.blank?

      census_update = CensusLoading::Update.new(census_data_type, update)

      data_set = CensusDataSet
          .on_db(census_update.shard)
          .where(census_update.data_set_attributes)
          .first_or_initialize
      data_set.on_db(census_update.shard).save

      value_record = census_update.value_class
          .on_db(census_update.shard)
          .where(census_update.entity_id_type => census_update.entity_id, data_set_id: data_set.id)
          .first_or_initialize

      value_record.on_db(census_update.shard).update_attributes(
          active: true,
          census_update.value_type => census_update.value,
          modified: Time.now,
          modifiedBy: "Queue daemon. Source: #{source}"
      )
    end
  end

end
