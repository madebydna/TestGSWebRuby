class CensusLoading::Loader < CensusLoading::Base

  CACHE_KEY = 'characteristics'
  DATA_TYPE = :census

  # Best ordering: first create data sets, then gs_schooldb.census_* rows, then value row

  def load!

    census_data_type = census_data_type_from_name(data_type)

    updates.each do |update|
      next if update.blank?

      census_update = CensusLoading::Update.new(census_data_type, update)

      # Raises entity not found exception if one doesn't exist with that ID
      unless census_update.entity_type == :state
        entity = census_update.entity_type.to_s.constantize.on_db(census_update.shard).find(census_update.entity_id)
      end

      begin
        if census_update.action == ACTION_DISABLE
          disable!(census_update)
          # If we choose to support delete later, we can uncomment this and then create the delete method below
          # elsif census_update.action == 'delete'
          #   delete!(census_update)
        elsif census_update.action == ACTION_BUILD_CACHE
          # do nothing
        else
          insert_into!(census_update, entity)
        end
      rescue Exception => e
        raise e.message
      ensure
        unless census_update.action == ACTION_NO_CACHE_BUILD
          Cacher.create_caches_for_data_type(entity, DATA_TYPE) if entity.is_a?(School)
        end
      end
    end
  end

  def insert_into!(census_update, entity)

    data_set = CensusDataSet.find_or_create_and_activate(census_update.shard, census_update.data_set_attributes)
    # validate_census_data_set!(data_set, census_update)

    school_type = entity.respond_to?(:type) ? entity.type : 'public'
    configure_census_description!(census_update.census_description_attributes, school_type, data_set.id)

    value_row_attributes = { data_set_id: data_set.id }
    unless census_update.entity_type == :state
      value_row_attributes.merge!({ census_update.entity_id_type => census_update.entity_id })
    end
    value_row = census_update.value_class
      .on_db(census_update.shard)
      .where(value_row_attributes)
      .first_or_initialize

    # validate_census_value!(value_row, data_set, census_update)
    value_row.on_db(census_update.shard).update_attributes(
      active: 1,
      value_text: census_update.value_type == :value_text ? census_update.value : nil,
      value_float: census_update.value_type == :value_float ? census_update.value : nil,
      modified: Time.now,
      modifiedBy: source
    )

  end

  def configure_census_description!(attributes, school_type, data_set_id)
    attributes.merge!(
        { census_data_set_id: data_set_id,
          school_type: school_type }
    )
    CensusDescription.where(attributes).first_or_create!
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
          # validate_census_value!(value_row, data_set, census_update)
          value_row.on_db(census_update.shard).update_attributes(active: 1)
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

    errors << "The year column does not match. Values - Java: #{data_set.year} Ruby:#{census_update.data_set_attributes[:year]}" unless data_set.year.to_s == census_update.data_set_attributes[:year].to_s
    errors << "The grade column does not match. Values - Java: #{data_set.grade} Ruby:#{census_update.data_set_attributes[:grade]}" unless data_set.grade.to_s == census_update.data_set_attributes[:grade].to_s
    errors << "The data_type_id column does not match. Values - Java: #{data_set.data_type_id} Ruby:#{census_update.data_set_attributes[:data_type_id]}" unless data_set.data_type_id.to_s == census_update.data_set_attributes[:data_type_id].to_s
    errors << "The breakdown_id column does not match. Values - Java: #{data_set.breakdown_id} Ruby:#{census_update.data_set_attributes[:breakdown_id]}" unless data_set.breakdown_id.to_s == census_update.data_set_attributes[:breakdown_id].to_s
    errors << "The subject_id column does not match. Values - Java: #{data_set.subject_id} Ruby:#{census_update.data_set_attributes[:subject_id]}" unless data_set.subject_id.to_s == census_update.data_set_attributes[:subject_id].to_s

    raise errors.unshift("Census Data Set ##{data_set.id}").join("\n") if errors.present?
  end

  def validate_census_value!(value_row, data_set, census_update)
    errors = []

    raise "Value row does not exist" unless value_row.id.present?

    errors << "The active column does not match. Values - Java: #{value_row.active} Ruby: 1" unless [1, true].include? value_row.active # [1, true] because ActiveRecord returns either
    errors << "The school_id column does not match. Values - Java: #{value_row.school_id} Ruby:#{census_update.entity_id}" unless value_row.school_id.to_s == census_update.entity_id.to_s

    update_value_text =  census_update.value_type == :value_text ? census_update.value.to_s : nil
    update_value_float =  census_update.value_type == :value_float ? census_update.value.to_f : nil
    errors << "The value_text column does not match. Values - Java: #{value_row.value_text} Ruby:#{update_value_text}" unless value_row.value_text.to_s == update_value_text.to_s
    errors << "The value_float column does not match. Values - Java: #{value_row.value_float} Ruby:#{update_value_float}" unless value_row.value_float.to_s == update_value_float.to_s

    errors << "The data_set_id column does not match. Values - Java: #{value_row.data_set_id} Ruby:#{data_set.id}" unless value_row.data_set_id.to_s == data_set.id.to_s

    raise errors.unshift("#{census_update.entity_type} ##{value_row.school_id} Census Value").join("\n") if errors.present?
  end

end
