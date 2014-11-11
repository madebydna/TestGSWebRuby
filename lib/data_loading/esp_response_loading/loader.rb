class EspResponseLoading::Loader < EspResponseLoading::Base

  def load!
    puts self.class

    updates.each do |update|
      next if update.blank?

      esp_response_update = EspResponseLoading::Update.new(data_type, update, source)

      if esp_response_update.action == 'disable'
        disable!(esp_response_update)
      # If we choose to support delete later, we can uncomment this and then create the delete method below
      # elsif esp_response_update.action == 'delete'
      #   delete!(esp_response_update)
      else
        insert_into!(esp_response_update)
      end
    end
  end

  def validate_esp_response!(value_row, esp_response_update)
    errors = []

    raise "Value row does not exist" unless value_row.id.present?

    errors << "The active column does not match. Values - Java: #{value_row.active} Ruby: true" unless [1, true].include? value_row.active # [1, true] because ActiveRecord returns either
    errors << "The school_id column does not match. Values - Java: #{value_row.school_id} Ruby:#{esp_response_update.entity_id}" unless value_row.school_id == esp_response_update.entity_id
    errors << "The esp_source column does not match. Values - Java: #{value_row.esp_source} Ruby:#{esp_response_update.source}" unless value_row.esp_source == esp_response_update.source
    errors << "The response_key column does not match. Values - Java: #{value_row.response_key} Ruby:#{esp_response_update.data_type}" unless value_row.response_key == esp_response_update.data_type
    errors << "The response_value column does not match. Values - Java: #{value_row.response_value} Ruby:#{esp_response_update.value}" unless value_row.response_value == esp_response_update.value
    errors << "The member_id column does not match. Values - Java: #{value_row.member_id} Ruby:#{esp_response_update.member_id}" unless value_row.member_id == esp_response_update.member_id

    raise errors.unshift("SCHOOL ##{value_row.school_id} ESP Response").join("\n") if errors.present?

  end

  def insert_into!(esp_response_update)

    value_row = EspResponse
      .on_db(esp_response_update.shard)
      .where(esp_response_update.attributes)
      .first_or_initialize

    value_row.on_db(esp_response_update.shard).update_attributes(
      active: 1,
      created: Time.now,
      esp_source: esp_response_update.source,
      member_id: esp_response_update.member_id
    )

  end

  def disable!(esp_response_update)
    value_row = EspResponse
      .on_db(esp_response_update.shard)
      .where(esp_response_update.attributes)
      .where(active: 1)

    if value_row.present?
      value_row.each do | row |
        row.on_db(esp_response_update.shard).update_attributes(active: 0)
      end
    end
  end

  def delete!(esp_response_update)
    # db_charmer below does not support deletes at least in its current form. Will have to write straight sql for delete action
    # EspResponse.on_db(esp_response_update.shard)
    #   .where(esp_response_update.attributes)
    #   .destroy_all
  end

end