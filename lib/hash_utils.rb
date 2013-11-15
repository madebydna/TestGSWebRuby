module HashUtils

  def self.merge_keys (some_hash, key1, key2, result_key)

    value1 = some_hash[key1]
    value2 = some_hash[key2]
    if value1.present? && value2.present?
      result = yield value1, value2
      some_hash[result_key] = result
    end
  end

  def self.split_keys (some_hash, key)
    value = some_hash[key]
    if value.present?
      result_hash = yield value
      some_hash.merge!(result_hash)
    end
  end
end