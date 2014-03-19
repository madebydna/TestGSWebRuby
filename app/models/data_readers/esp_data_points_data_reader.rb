class EspDataPointsDataReader < SchoolProfileDataReader

  def data_for_category(_)
    data = EspResponse.on_db(school.shard).where(school_id: school.id).active

    unless data.nil?
      # since esp_response has multiple rows with the same key, roll up all values for a key into an array
      responses_per_key = data.group_by(&:response_key)
      responses_per_key.values.each { |values| values.map!(&:response_value) }
    end

    #Merge start_time and end_time into hours.
    HashUtils.merge_keys responses_per_key, 'start_time', 'end_time', 'hours' do |value1 ,value2|
      value1.first.to_s + ' - ' + value2.first.to_s
    end

    #Split before_after_care into before_care and after_care.
    HashUtils.split_keys responses_per_key, 'before_after_care' do |value|
      result_hash = {}
      if value.kind_of?(Array)
        value.each do |val|
          result_hash[val.downcase + "_care"] = 'yes'
        end
      elsif value == 'neither'
        result_hash["before_care"] = 'no'
        result_hash["after_care"] = 'no'
      end

      result_hash
    end

    if responses_per_key['transportation'].present? && ( (Array(responses_per_key['transportation']).first).casecmp('none') != 0)
      responses_per_key['transportation'] = 'Yes'
    end

    responses_per_key
  end

end