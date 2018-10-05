class Hash

  def gs_remove_empty_values
    delete_if { |k, v| v.blank? }
  end

  def gs_rename_keys!(&block)
    replace gs_rename_keys(&block)
  end

  def gs_rename_keys(&block)
    gs_recursive_call do |key, value|
      [ block.call(key), value ]
    end
  end

  def gs_rename_keys_using_lookup(hash)
    gs_rename_keys do |key|
      hash[key].presence || key
    end
  end

  def gs_rename_keys_using_lookup!(hash)
    replace gs_rename_keys_using_lookup(hash)
  end

  def gs_recursive_call(*args, &block)
    each_with_object({}) do |pair, hash|
      pair = pair.gs_recursive_call_on_pair(*args) do |obj|
          if obj.is_a? Array
            block.call(obj)
          else
            obj
          end
      end
      hash[pair[0]] = pair[1] if pair
    end
  end

  def gs_transform_values(&block)
    gs_recursive_call do |key, value|
      [ key, block.call(value) ]
    end
  end

  def gs_transform_values!(&block)
    replace gs_transform_values(&block)
  end

  def gs_recursive_each_with_clone(&blk)
    new_hash = clone
    each do |k, v|
      if v.is_a? Hash
        v.gs_recursive_each_with_clone(&blk)
        blk.call([new_hash, k, v])
      else
        blk.call([new_hash, k, v])
      end
    end
    replace new_hash
  end

  def except(*keys)
    dup.except!(*keys)
  end

  # Replaces the hash without the given keys.
  def except!(*keys)
    keys.each { |key| delete(key) }
    self
  end

  def seek(*keys)
    last_level    = self
    sought_value  = nil

    keys.each_with_index do |key, idx|
      if last_level.is_a?(Hash) && last_level.has_key?(key)
        if idx + 1 == keys.length
          sought_value = last_level[key]
        else
          last_level = last_level[key]
        end
      else
        break
      end
    end

    sought_value
  end

  def gs_sort_by_key(recursive = false, &block)
    self.keys.sort(&block).reduce({}) do |seed, key|
      seed[key] = self[key]
      if recursive && seed[key].is_a?(Hash)
        seed[key] = seed[key].gs_sort_by_key(true, &block)
      end
      seed
    end
  end

  def gs_dig(*path)
    path.inject(self) do |location, key|
      location.respond_to?(:keys) ? location[key] : nil
    end
  end
end

#can use HashWithSetterCallback class below or just mixin this module into your hash
#the latter will allow you to keep a hash object that uses any custom initializers
module Hash::SetterCallback
  def self.set_setter_callback!(&callback)
    @setter_callback = callback
  end

  def set_setter_callback!(&callback)
    @setter_callback = callback
  end

  def []=(key, value)
    key, value = @setter_callback.call(key, value) if @setter_callback.present?
    super(key, value)
  end
end

class HashWithSetterCallback < Hash
  include Hash::SetterCallback

  def initialize(&callback)
    set_setter_callback!(&callback)
  end

end
