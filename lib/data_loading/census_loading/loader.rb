class CensusLoading::Loader < CensusLoading::Base

  CACHE_KEY = 'characteristics'

  # TODO handle census_description, census_data_set_file
  # Best ordering: first create data sets, then gs_schooldb.census_* rows, then value row
  # TODO break out data set code into module

  def load!

    census_data_type = census_data_types[data_type]

    updates.each do |update|
      next if update.blank?

      census_update = CensusLoading::Update.new(census_data_type, update)

      # Raises school not found exception if one doesn't exist with that ID
      school = School.on_db(census_update.shard).find(census_update.entity_id)

      if census_update.action == 'disable'
        disable!(census_update)
      # If we choose to support delete later, we can uncomment this and then create the delete method below
      # elsif census_update.action == 'delete'
      #   delete!(census_update)
      else
        insert_into!(census_update)
      end

      Cacher.create_cache(school, CACHE_KEY)
    end
  end

  def insert_into!(census_update)

    data_set = CensusDataSet
      .on_db(census_update.shard)
      .where(census_update.data_set_attributes)
      .first_or_initialize

    validate_census_data_set!(data_set, census_update)
    # data_set.on_db(census_update.shard).update_attributes(active: 1)

    value_row = census_update.value_class
      .on_db(census_update.shard)
      .where(census_update.entity_id_type => census_update.entity_id, data_set_id: data_set.id)
      .first_or_initialize

    validate_census_value!(value_row, data_set, census_update)
    # value_row.on_db(census_update.shard).update_attributes(
    #   active: 1,
    #   value_text: census_update.value_type == :value_text ? census_update.value : nil,
    #   value_float: census_update.value_type == :value_float ? census_update.value : nil,
    #   modified: Time.now,
    #   modifiedBy: "Queue daemon. Source: #{source}"
    # )

  end

  def disable!(census_update)

    data_sets = CensusDataSet
      .on_db(census_update.shard)
      .where(census_update.data_set_attributes)
      .where(active: 1)

    if data_sets.present?
      data_sets.each do | data_set |
        validate_census_data_set!(data_set, census_update)

        value_rows = census_update.value_class
          .on_db(census_update.shard)
          .where(census_update.entity_id_type => census_update.entity_id, data_set_id: data_set.id)

        value_rows.each do | value_row |
          validate_census_value!(value_row, data_set, census_update)
          # value_row.on_db(census_update.shard).update_attributes(active: 1)
        end
      end
    end

  end

  def delete!(census_update)

    # db_charmer below does not support deletes at least in its current form. Will have to write straight sql for delete action
    # data_set = CensusDataSet
    #   .on_db(census_update.shard)
    #   .where(census_update.data_set_attributes).first
    #
    # census_update.value_class
    #   .on_db(census_update.shard)
    #   .where(census_update.entity_id_type => census_update.entity_id, data_set_id: data_set.id)
    #   .destroy
    #
    # data_set.destroy

  end

  def validate_census_data_set!(data_set, census_update)
    errors = []

    raise "Data set row does not exist" unless data_set.id.present?

    errors << "The active column does not match. Values - Java: #{data_set.active} Ruby: 1" unless [1, true].include? data_set.active # [1, true] because ActiveRecord returns either

    errors << "The year column does not match. Values - Java: #{data_set.year} Ruby:#{census_update.data_set_attributes[:year]}" unless data_set.year == census_update.data_set_attributes[:year]
    errors << "The grade column does not match. Values - Java: #{data_set.grade} Ruby:#{census_update.data_set_attributes[:grade]}" unless data_set.grade == census_update.data_set_attributes[:grade]
    errors << "The data_type_id column does not match. Values - Java: #{data_set.data_type_id} Ruby:#{census_update.data_set_attributes[:data_type_id]}" unless data_set.data_type_id == census_update.data_set_attributes[:data_type_id]
    errors << "The breakdown_id column does not match. Values - Java: #{data_set.breakdown_id} Ruby:#{census_update.data_set_attributes[:breakdown_id]}" unless data_set.breakdown_id == census_update.data_set_attributes[:breakdown_id]
    errors << "The subject_id column does not match. Values - Java: #{data_set.subject_id} Ruby:#{census_update.data_set_attributes[:subject_id]}" unless data_set.subject_id == census_update.data_set_attributes[:subject_id]

    raise errors.unshift("Census Data Set ##{data_set.id}").join("\n") if errors.present?
  end

  def validate_census_value!(value_row, data_set, census_update)
    errors = []

    raise "Value row does not exist" unless value_row.id.present?

    errors << "The active column does not match. Values - Java: #{value_row.active} Ruby: 1" unless [1, true].include? value_row.active # [1, true] because ActiveRecord returns either
    errors << "The school_id column does not match. Values - Java: #{value_row.school_id} Ruby:#{census_update.entity_id}" unless value_row.school_id == census_update.entity_id

    update_value_text =  census_update.value_type == :value_text ? census_update.value : nil
    update_value_float =  census_update.value_type == :value_float ? census_update.value : nil
    errors << "The value_text column does not match. Values - Java: #{value_row.value_text} Ruby:#{update_value_text}" unless value_row.value_text == update_value_text
    errors << "The value_float column does not match. Values - Java: #{value_row.value_float} Ruby:#{update_value_float}" unless value_row.value_float == update_value_float

    errors << "The data_set_id column does not match. Values - Java: #{value_row.data_set_id} Ruby:#{data_set.id}" unless value_row.data_set_id == data_set.id

    raise errors.unshift("#{census_update.entity_type} ##{value_row.school_id} Census Value").join("\n") if errors.present?
  end

end
