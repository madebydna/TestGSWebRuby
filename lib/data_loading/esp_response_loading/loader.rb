class EspResponseLoading::Loader < EspResponseLoading::Base

  def load!
    puts self.class

    updates.each do |update|
      next if update.blank?

      esp_response_update = EspResponseLoading::Update.new(data_type, update)

      value_row = EspResponse
          .on_db(esp_response_update.shard)
          .where(esp_response_update.attributes)
          .first_or_initialize

      errors = []
      raise "Value row does not exist" unless value_row.id.present?

      errors << "The active column does not match. Values - Java: true Ruby: false" unless value_row.active == true
      errors << "The school_id column does not match. Values - Java: #{value_row.school_id} Ruby:#{esp_response_update.entity_id}" unless value_row.school_id == esp_response_update.entity_id
      errors << "The esp_source column does not match. Values - Java: #{value_row.esp_source} Ruby:#{source}" unless value_row.esp_source == source
      errors << "The response_key column does not match. Values - Java: #{value_row.response_key} Ruby:#{esp_response_update.data_type}" unless value_row.response_key == esp_response_update.data_type
      errors << "The response_value column does not match. Values - Java: #{value_row.response_value} Ruby:#{esp_response_update.value}" unless value_row.response_value == esp_response_update.value
      errors << "The member_id column does not match. Values - Java: #{value_row.member_id} Ruby:#{esp_response_update.member_id}" unless value_row.member_id == esp_response_update.member_id

      raise errors.unshift("SCHOOL ##{value_row.school_id} ESP Response").join("\n") if errors.present?

      # value_row.on_db(esp_response_update.shard).update_attributes(
      #     active: true,
      #     created: Time.now,
      #     esp_source: source,
      #     member_id: esp_response_update.member_id
      # )
    end
  end

end