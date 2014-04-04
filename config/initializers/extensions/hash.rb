class Hash

  def gs_rename_keys!(&block)
    replace gs_rename_keys(&block)
  end

  def gs_rename_keys(&block)
    gs_recursive_call do |key, value|
      [ block.call(key), value ]
    end
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
end