class EspResponseLoading::Loader < EspResponseLoading::Base

  CACHE_KEY = 'esp_responses'
  DATA_TYPE = :esp_response

  def load!

    updates.each do |update|
      next if update.blank?

      esp_response_update = EspResponseLoading::Update.new(data_type, update, source)

      school = School.on_db(esp_response_update.shard).find(esp_response_update.entity_id)

      begin
        @existing_values_for_response_key ||= (
          EspResponse
          .on_db(esp_response_update.shard)
          .where(esp_response_update.attributes)
          .where(active: 1)
        )
        if esp_response_update.action == ACTION_DISABLE
          disable!(esp_response_update,@existing_values_for_response_key)
          # If we choose to support delete later, we can uncomment this and then create the delete method below
          # elsif esp_response_update.action == 'delete'
          #   delete!(esp_response_update)
        elsif esp_response_update.action == ACTION_BUILD_CACHE
          # do nothing
        else
          handle_update(esp_response_update, @existing_values_for_response_key)
        end
      rescue Exception => e
        raise e.message
      ensure
        unless esp_response_update.action == ACTION_NO_CACHE_BUILD
          Cacher.create_caches_for_data_type(school, DATA_TYPE)
        end
      end
    end
  end

  class EspResponseValueUpdate
    def initialize(esp_response_update, value_row)
      @esp_response_update = esp_response_update
      @value_row = value_row
    end
    attr_reader :value_row, :esp_response_update

    def should_be_active?
      value_row.present? && esp_response_update.created_before?(value_row.created) || value_row.blank?
    end

    def should_be_disabled?
      value_row.present? && esp_response_update.created_before?(value_row.created)
    end
  end

  def handle_update(esp_response_update, value_row)
    value_info = EspResponseValueUpdate.new(esp_response_update, value_row.first)

    if value_info.should_be_active? && value_info.should_be_disabled?
      disable!(esp_response_update, value_row)
    end

    insert_into!(esp_response_update, active: value_info.should_be_active?)
  end

  def validate_esp_response!(value_row, esp_response_update)
    errors = []

    raise "Value row does not exist" unless value_row.id.present?

    errors << "The active column does not match. Values - Java: #{value_row.active} Ruby: true" unless [1, true].include? value_row.active # [1, true] because ActiveRecord returns either
    errors << "The school_id column does not match. Values - Java: #{value_row.school_id} Ruby:#{esp_response_update.entity_id}" unless value_row.school_id.to_s == esp_response_update.entity_id.to_s
    errors << "The esp_source column does not match. Values - Java: #{value_row.esp_source} Ruby:#{esp_response_update.source}" unless value_row.esp_source.to_s == esp_response_update.source.to_s
    errors << "The response_key column does not match. Values - Java: #{value_row.response_key} Ruby:#{esp_response_update.data_type}" unless value_row.response_key.to_s == esp_response_update.data_type.to_s
    errors << "The response_value column does not match. Values - Java: #{value_row.response_value} Ruby:#{esp_response_update.value}" unless value_row.response_value.to_s == esp_response_update.value.to_s
    errors << "The member_id column does not match. Values - Java: #{value_row.member_id} Ruby:#{esp_response_update.member_id}" unless value_row.member_id.to_s == esp_response_update.member_id.to_s

    raise errors.unshift("SCHOOL ##{value_row.school_id} ESP Response").join("\n") if errors.present?
  end

  def insert_into!(esp_response_update, attributes = {})
    esp_response = EspResponse.new_from_esp_response_update(esp_response_update)
    esp_response.attributes = attributes
    esp_response.on_db(esp_response_update.shard).save
  end

  def disable!(esp_response_update,value_row)
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