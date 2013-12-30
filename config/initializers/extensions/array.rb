class Array

  def gs_recursive_call(*args, &block)
    self.map do |obj|
      if obj.is_a? Hash
        obj.gs_recursive_call *args, &block
      elsif obj.is_a? Array
        obj.gs_recursive_call *args, &block
      else
        block.call(obj)
      end
    end
  end

  def gs_recursive_call_on_pair(*args, &block)
    key = self[0]
    value = self[1]
    if value.is_a? Hash
      block.call([ key, value.gs_recursive_call(*args, &block) ])
    elsif value.is_a? Array
      block.call([ key, value.gs_recursive_call(*args, &block) ])
    else
      block.call(self)
    end
  end


end