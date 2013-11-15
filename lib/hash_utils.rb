module HashUtils

  def self.merge_keys (merged_hash, key1, key2, result_key)

    value1 = merged_hash[key1]
    value2 = merged_hash[key2]
    if value1.present? && value2.present?
      result = yield value1, value2
      merged_hash[result_key] = result
    end
  end

  def self.split_keys (merged_hash, key)
    value = merged_hash[key]
    if value.present?
      result_hash = yield value
      merged_hash.merge!(result_hash)
    end
  end
end