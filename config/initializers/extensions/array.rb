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

  # Takes:
  #  [
  #     {
  #         key: 'name',
  #         direction: 'ascending'
  #     },
  #     {
  #         key: 'school_value',
  #         direction: 'descending'
  #     }
  #  ]
  #
  #  or simply
  #
  #  { key: 'name', direction: 'ascending' }
  #
  # Will sort the objects or hashes in this array, according to the provided keys and directions
  def gs_multisort(array_of_options)
    array_of_options = [array_of_options] if array_of_options.is_a? Hash

    sort do |row1, row2|
      left_values = []
      right_values = []

      array_of_options.each do |config|
        config.symbolize_keys!

        attribute = config[:key].to_sym
        direction = config[:direction]

        # default direction to ascending
        ascending = direction != 'descending'

        row1_value = ((row1.is_a? Hash)? row1[attribute] : row1.send(attribute))
        row2_value = ((row2.is_a? Hash)? row2[attribute] : row2.send(attribute))

        # When we eventually compare all the left_values and right_values, we can't compare a nil with a non-nil value
        # So if one of the values is nil, just ensure both values are of the same type, and that the nil will be _last_
        if row1_value.nil? && row2_value
          row1_value = ascending ? 1:0
          row2_value = ascending ? 0:1
        elsif row2_value.nil? && row1_value
          row1_value = ascending ? 0:1
          row2_value = ascending ? 1:0
        end

        if ascending
          # If object in array is a hash, look up the value. Otherwise, call a method to get the value
          left_values << row1_value
          right_values << row2_value
        else
          left_values << row2_value
          right_values << row1_value
        end
      end

      left_values <=> right_values
    end
  end

  def gs_multisort!(*args)
    array = gs_multisort *args
    replace array
  end


end