class Hash

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
      if Hash === v
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

  def seek(*_keys_)
    last_level    = self
    sought_value  = nil

    _keys_.each_with_index do |_key_, _idx_|
      if last_level.is_a?(Hash) && last_level.has_key?(_key_)
        if _idx_ + 1 == _keys_.length
          sought_value = last_level[_key_]
        else
          last_level = last_level[_key_]
        end
      else
        break
      end
    end

    sought_value
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
